//
//  PollData.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 03/05/23.
//

import Foundation

struct PollData {
    
    struct Option: Identifiable {
        let id: Int
        let text: String
        var voteCount: Int
    }
    
    let options: [Option]
    let votingEndDate: Date?
    let isPrediction: Bool
    
    init(pollData: [String : Any]) {
        
        let optionsData = pollData.getDictionaryArray("options")!
                
        options = optionsData.map{ option in
            let id = Int(option["id"] as! String) ?? 0
            let text: String = option.get("text")
            let voteCount: Int = option.get("vote_count") ?? 0
            return Option(id: id, text: text, voteCount: voteCount)
        }
        
        votingEndDate = pollData.getDate("voting_end_timestamp")
        isPrediction = pollData.getBool("is_prediction")
        
    }
}
