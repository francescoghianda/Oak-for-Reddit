//
//  AsyncUIImage.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 31/03/23.
//

import SwiftUI

fileprivate class ImageCache {
    
    var maxSize: Int = 40
    
    private var cachedImages: [URL : UIImage] = [:]
    private var cacheAccesses: [URL : Date] = [:]
    
    subscript(url: URL) -> UIImage? {
        get {
            
            if let image = cachedImages[url] {
                cacheAccesses[url] = .now
                return image
            }
            return nil
        }
        
        set(image) {
            
            cachedImages[url] = image
            cacheAccesses[url] = .now
            
            if cachedImages.count > maxSize {
                
                let sorted = cacheAccesses.sorted { $0.1 < $1.1 }
                let urls = Array(sorted[0..<sorted.count/2]).map { $0.0 }
                
                urls.forEach { url in
                    cachedImages.removeValue(forKey: url)
                    cacheAccesses.removeValue(forKey: url)
                }
                
            }
            
        }
    }
    
}

class AsyncImageLoader: ObservableObject {
    
    @Published private(set) var image: UIImage? = nil
    @Published private(set) var error: Bool? = nil
    @Published private(set) var progress: Double = .zero
    
    private var observation: NSKeyValueObservation? = nil
    
    //private static var cachedImages: [URL : UIImage] = [:]
    private static var imageCache = ImageCache()
    
    public func load(url: URL, then: ((_ image: UIImage?, _ error: Bool?, _ cached: Bool) -> Void)? = nil) {
                
        if let image = AsyncImageLoader.imageCache[url] {
            then?(image, nil, true)
            self.image = image
            return
        }
        
        var request = URLRequest(url: url)
        
        request.cachePolicy = .returnCacheDataElseLoad
        
        let cached: Bool = URLCache.shared.cachedResponse(for: request) != nil
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard
                let data = data,
                let response = response as? HTTPURLResponse,
                error == nil
            else {
                DispatchQueue.main.async {
                    self?.error = true
                    then?(nil, true, cached)
                }
                return
            }
            
            if response.statusCode >= 400 {
                DispatchQueue.main.async {
                    self?.error = true
                    then?(nil, true, cached)
                }
                return
            }
            
            if let image = UIImage(data: data){
                //AsyncImageLoader.imageCache[url] = image
                DispatchQueue.main.async {
                    self?.image = image
                    then?(image, nil, cached)
                }
            }
            else {
                DispatchQueue.main.async {
                    self?.error = true
                    then?(nil, true, cached)
                }
            }
            
        }
        
        observation = task.progress.observe(\.fractionCompleted) { [weak self] progress, _ in
            DispatchQueue.main.async {
                self?.progress = progress.fractionCompleted
            }
        }
        
        task.resume()
        
    }
    
    deinit {
        observation?.invalidate()
    }
    
}

struct AsyncUIImage<Content: View>: View {
    
    @ViewBuilder private let content: (_ image: UIImage?, _ error: Bool?) -> Content
    
    @StateObject fileprivate var loader = AsyncImageLoader()
    
    private var imageBinding: Binding<UIImage?>?
        
    let url: URL
    private(set) var onFirstLoad: ((UIImage) -> Void)?
    
    init(url: URL, image: Binding<UIImage?>? = nil,
         @ViewBuilder content: @escaping (_ image: UIImage?, _ error: Bool?) -> Content,
         onFirstLoad: ((UIImage) -> Void)? = nil) {

        self.content = content
        self.url = url
        self.imageBinding = image
        self.onFirstLoad = onFirstLoad
    }
    
    func onFirstLoad(_ perform: ((UIImage) -> Void)? = nil) -> AsyncUIImage<Content> {
        var view = self
        view.onFirstLoad = perform
        return view
    }
    
    var body: some View {
        
        content(loader.image, loader.error)
            .onAppear {
                loader.load(url: url) { (image, error, cached) in
                    if let image = image{
                        imageBinding?.wrappedValue = image
                        
                        if !cached{
                            onFirstLoad?(image)
                        }
                    }
                    
                }
            }
        
    }
}

class ImageSaver: NSObject {
    
    private var onImageSavedHandler: (() -> Void)?
    private var onError: ((Error) -> Void)?
    
    init(onImageSaved: (() -> Void)? = nil, onError: ((Error) -> Void)? = nil) {
        self.onImageSavedHandler = onImageSaved
        self.onError = onError
    }

    func saveImage(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
    }
    
    func onImageSaved(_ perform: @escaping () -> Void) -> ImageSaver {
        self.onImageSavedHandler = perform
        return self
    }

    @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            onError?(error)
        } else {
            onImageSavedHandler?()
        }
    }
}

/*struct AsyncUIImage_Previews: PreviewProvider {
    static var previews: some View {
        AsyncUIImage()
    }
}*/
