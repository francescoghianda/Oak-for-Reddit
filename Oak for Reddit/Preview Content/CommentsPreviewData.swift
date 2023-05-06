//
//  CommentsData.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 06/05/23.
//

import Foundation

struct CommentsPreviewData {
    
    private static let commentJson: String = """
    {
        "kind": "t1",
        "data": {
            "author_flair_background_color": null,
            "subreddit_id": "t5_89iy4l",
            "approved_at_utc": null,
            "author_is_blocked": false,
            "comment_type": null,
            "awarders": [],
            "mod_reason_by": null,
            "banned_by": null,
            "author_flair_type": "text",
            "total_awards_received": 0,
            "subreddit": "oakforreddit",
            "removed": false,
            "author_flair_template_id": null,
            "likes": true,
            "replies": "",
            "user_reports": [],
            "saved": false,
            "id": "jj2op0d",
            "banned_at_utc": null,
            "mod_reason_title": null,
            "gilded": 0,
            "archived": false,
            "collapsed_reason_code": null,
            "no_follow": false,
            "author": "Francy5615",
            "rte_mode": "richtext",
            "can_mod_post": true,
            "send_replies": true,
            "parent_id": "t3_12u28fd",
            "score": 1,
            "author_fullname": "t2_joesrk6",
            "removal_reason": null,
            "approved_by": null,
            "mod_note": null,
            "all_awardings": [],
            "collapsed": false,
            "body": "**Lorem Ipsum** is simply dummy text of the printing and typesetting industry. \\n\\nLorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.",
            "edited": false,
            "top_awarded_type": null,
            "author_flair_css_class": null,
            "name": "t1_jj2op0d",
            "is_submitter": true,
            "downs": 0,
            "author_flair_richtext": [],
            "author_patreon_flair": false,
            "gildings": {},
            "collapsed_reason": null,
            "distinguished": null,
            "associated_award": null,
            "stickied": false,
            "author_premium": false,
            "can_gild": false,
            "link_id": "t3_12u28fd",
            "unrepliable_reason": null,
            "approved": false,
            "author_flair_text_color": null,
            "score_hidden": false,
            "permalink": "/r/oakforreddit/comments/12u28fd/test_galleria_nsfw/jj2op0d/",
            "subreddit_type": "private",
            "locked": false,
            "report_reasons": [],
            "created": 1683370106.0,
            "author_flair_text": null,
            "treatment_tags": [],
            "spam": false,
            "created_utc": 1683370106.0,
            "subreddit_name_prefixed": "r/oakforreddit",
            "controversiality": 0,
            "depth": 0,
            "ignore_reports": false,
            "collapsed_because_crowd_control": null,
            "mod_reports": [],
            "num_reports": 0,
            "ups": 1
        }
    }
    """
    
    /*
     "body_html": "&lt;div class=\"md\"&gt;&lt;p&gt;&lt;strong&gt;Lorem Ipsum&lt;/strong&gt; is simply dummy text of the printing and typesetting industry. &lt;/p&gt;\n\n&lt;p&gt;Lorem Ipsum has been the industry&amp;#39;s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.&lt;/p&gt;\n&lt;/div&gt;",
     */
    
    static var commentData: [String : Any] = {
        do {
            return try JSONSerialization.jsonObject(with: commentJson.data(using: .utf8)!, options: []) as! [String : Any]
        }
        catch {
            fatalError("Error parsing json: \(error)")
        }
        
    }()
    
    static var comment: Comment = {
        Thing.build(from: commentData)
    }()
    
}
