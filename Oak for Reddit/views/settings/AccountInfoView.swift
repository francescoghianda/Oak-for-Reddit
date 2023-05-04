//
//  AccountInfoView.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 24/04/23.
//

import SwiftUI
import CoreData

fileprivate struct AccountIcon: View {
    
    @ObservedObject var account: Account
    
    var body: some View {
        
        if let avatarUrl = account.avatarUrl {
            
            AsyncImage(url: avatarUrl) { image in
                
                image
                    .resizable()
                    .scaledToFit()
            } placeholder: {
                Color.clear
            }
            
        }
        else {
            Circle()
                .strokeBorder(.primary, lineWidth: 2)
                .background {
                    ZStack{
                        Circle()
                            .background(.ultraThinMaterial)
                            .opacity(0.9)
                        AsyncImage(url: account.imageUrl) { image in
                            
                            image
                                .resizable()
                                .scaledToFit()
                            
                        } placeholder: {
                            ProgressView()
                        }
                    }
                    .clipShape(Circle())
                }
        }
        
    }
    
}

struct AccountInfoView: View {
    
    @FetchRequest(entity: Account.entity(), sortDescriptors: [], predicate: NSPredicate(format: "guest == %@", NSNumber(value: false)))
    private var accounts: FetchedResults<Account>
    
    @Environment(\.managedObjectContext) private var moc
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @State var confirmDialogPresented: Bool = false
    
    var body: some View {
        
        if let account = accounts.first {
            
            VStack {
                
                HStack {
                    
                    Spacer()
                    
                }
                .frame(height: horizontalSizeClass == .regular ? 350 : 250)
                .background(.teal)
                .overlay {
                    if let bannerUrl = account.bannerUrl {
                        AsyncImage(url: bannerUrl) { image in
                            image
                                .resizable()
                                .scaledToFill()
                                //.ignoresSafeArea()
                        } placeholder: {
                            Color.clear
                        }
                        
                    }
                }
                
                VStack(alignment: .leading) {
                    
                    if horizontalSizeClass == .regular {
                        
                        HStack(alignment: .top){
                            AccountIcon(account: account)
                                .frame(width: 200, height: 200)
                                //.offset(y: -100)
                                .padding(.leading)
                            
                            
                            if let name = account.name {
                                VStack(alignment: .leading) {
                                    Text(name)
                                        .lineLimit(1)
                                        .font(.largeTitle.bold())
                                    Text("u/\(name)")
                                        .foregroundColor(.gray)
                                }
                                .padding([.leading, .top])
                                .offset(y: 100)
                            }
                            
                        }
                        .padding(.trailing)
                    }
                    else {
                        
                        HStack(alignment: .top) {
                            
                            Spacer()
                            
                            VStack {
                                
                                AccountIcon(account: account)
                                    .frame(height: 200)
                                
                                if let name = account.name {
                                    Text(name)
                                        .lineLimit(1)
                                        .font(.largeTitle.bold())
                                    
                                    Text("u/\(name)")
                                        .foregroundColor(.gray)
                                }
                                    
                            }
                            
                            Spacer()
                        }
                    }
                    
                    HStack {
                        Spacer()
                        VStack(alignment: .leading){
                            
                            if horizontalSizeClass == .compact {
                                HStack{
                                    Spacer()
                                }
                            }
                            
                            LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], alignment: .center) {
                                
                                VStack {
                                    Label {
                                        Text("Karma")
                                            .font(.title2.bold())
                                    } icon: {
                                        Image(systemName: "atom")
                                            .foregroundStyle(.pink, .indigo)
                                            .frame(width: 24)
                                    }
                                    .padding(.bottom, 10)
                                    Text("1")
                                }
                                
                                VStack{
                                    Label {
                                        Text("Cake day")
                                            .font(.title2.bold())
                                    } icon: {
                                        Image(systemName: "birthday.cake.fill")
                                            .foregroundColor(.orange)
                                            .frame(width: 24)
                                    }
                                    .padding(.bottom, 10)
                                    Text("11 maggio 2018")
                                }
                                
                            }
                            .frame(maxWidth: horizontalSizeClass == .regular ? 500 : nil)
                            
                            
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(10)
                        //.frame(maxWidth: horizontalSizeClass == .regular ? nil : .infinity)
                        Spacer()
                    }
                    
                    
                    Spacer()
                    
                    HStack{
                        Spacer()
                        Button {
                            confirmDialogPresented = true
                        } label: {
                            Text("Logout")
                                .font(.title2.bold())
                                .foregroundColor(.white)
                                .padding()
                                .background(.red)
                                .cornerRadius(10)
                        }
                        .confirmationDialog("Are you sure you want to remove the account?", isPresented: $confirmDialogPresented, titleVisibility: .visible)
                        {
                            Button {
                                moc.delete(account)
                                try? moc.save()
                            } label: {
                                Text("Remove")
                            }

                        }
                        Spacer()
                    }
                    
                }
                .offset(y: horizontalSizeClass == .regular ? -100 : -150)
                .onAppear {
                    
                    account.loadAccountInfos()
                }
                
                Spacer()
                
            }
            //.background(colorScheme == .dark ? Color(UIColor.systemGray6) : .white)
            .ignoresSafeArea()
            
            
        }
        else {
            
            LoginWithRedditButton {
                OAuthManager.shared.authenticate()
            }
            
        }
        
        
    }
}

struct AccountInfoView_Previews: PreviewProvider {
    static var previews: some View {
        AccountInfoView()
    }
}
