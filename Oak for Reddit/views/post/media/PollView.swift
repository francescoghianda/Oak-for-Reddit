//
//  PollView.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 23/04/23.
//

import SwiftUI

fileprivate struct PollOptionView: View {
    
    let option: PollData.Option
    @Binding var maxTextSize: CGFloat
    let totalVotes: Int
    
    init(_ option: PollData.Option, totalVotes: Int, textSize: Binding<CGFloat>){
        self.option = option
        self.totalVotes = totalVotes
        self._maxTextSize = textSize
    }
    
    var body: some View {
        HStack {
            Text(option.text)
                .lineLimit(1)
                .overlay {
                    GeometryReader { geo in
                        Color.clear
                            .onAppear {
                                if maxTextSize < geo.size.width {
                                    maxTextSize = geo.size.width
                                }
                            }
                    }
                }
                .frame(minWidth: maxTextSize, maxWidth: 130, alignment: .leading)
                
            RoundedRectangle(cornerRadius: 10)
                .frame(height: 10)
                .foregroundColor(.primary)
                .overlay(alignment: .leading) {
                    
                    GeometryReader{ geo in
                        
                        let width = totalVotes > 0 ? (CGFloat(option.voteCount) / CGFloat(totalVotes)) * geo.size.width : 0
                        
                        RoundedRectangle(cornerRadius: 10)
                            .frame(width: width, height: 10)
                            .foregroundColor(.blue)
                            //.transition(.move(edge: .leading))
                            //.animation(.spring(), value: width)
                    }
                    
                }
        }
    }
    
}

struct PollView: View {
    
    let pollData: PollData
    let columns = [GridItem(.flexible(), spacing: 0), GridItem(.flexible(), spacing: 0)]
    
    @State private var barWidth: CGFloat = .zero
    @State private var maxTextSize: CGFloat = .zero
    
    var body: some View {
        
        let totalVotes = pollData.options.reduce(into: 0, { tot, option in
            tot = tot + option.voteCount
        })
        
        VStack {
            ForEach(pollData.options) { option in
                PollOptionView(option, totalVotes: totalVotes, textSize: $maxTextSize)
            }
            .overlay {
                GeometryReader { geo in
                    Color.clear
                        .onAppear {
                            barWidth = geo.size.width
                        }
                        .onChange(of: geo.size.width) { newValue in
                            barWidth = newValue
                        }
                }
            }
        }
        
    }
}

struct PollView_Previews: PreviewProvider {
    
    static let data: [String : Any] = [
        "is_prediction": 0,
        "voting_end_timestamp": 1682520785389,
        "options": [
            [
                "id": "22702009",
                "text": "Opzione 1 ciaoooooooooooooooooooooo",
                "vote_count": 3
            ],
            [
                "id": "22702010",
                "text": "Opzione 2",
                "vote_count": 2
            ],
            [
                "id": "22702011",
                "text": "Opzione 3",
                "vote_count": 5
            ]
        ]
    
    ]
    
    static var previews: some View {
        PollView(pollData: PollData(pollData: data))
            .padding()
            //.previewLayout(.sizeThatFits)
    }
}
