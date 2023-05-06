//
//  PostsData.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 06/05/23.
//

import Foundation

struct PostsPreviewData {
    
    
    private static let postJson: String = """
    {
        "kind": "t3",
        "data": {
          "author_flair_background_color": null,
          "approved_at_utc": null,
          "subreddit": "oakforreddit",
          "selftext": "",
          "author_fullname": "t2_joesrk6",
          "saved": false,
          "mod_reason_title": null,
          "gilded": 0,
          "clicked": false,
          "is_gallery": true,
          "title": "Test galleria NSFW",
          "link_flair_richtext": [],
          "subreddit_name_prefixed": "r/oakforreddit",
          "hidden": false,
          "pwls": null,
          "link_flair_css_class": null,
          "downs": 0,
          "thumbnail_height": 140,
          "top_awarded_type": null,
          "name": "t3_12u28fd",
          "media_metadata": {
            "sjl6pg2br8va1": {
              "status": "valid",
              "e": "Image",
              "m": "image/png",
              "o": [
                {
                  "y": 720,
                  "x": 512,
                  "u": "https://preview.redd.it/sjl6pg2br8va1.png?width=320&amp;blur=32&amp;format=pjpg&amp;auto=webp&amp;v=enabled&amp;s=c818c467664ed47e6c16b2dd0d71a3b11aaf670b"
                }
              ],
              "p": [
                {
                  "y": 151,
                  "x": 108,
                  "u": "https://preview.redd.it/sjl6pg2br8va1.png?width=108&amp;crop=smart&amp;auto=webp&amp;v=enabled&amp;s=72b08897fc876ad81f3805d0ea4313b189350220"
                },
                {
                  "y": 303,
                  "x": 216,
                  "u": "https://preview.redd.it/sjl6pg2br8va1.png?width=216&amp;crop=smart&amp;auto=webp&amp;v=enabled&amp;s=b6de77bdef8f5696b6a0c43e7c5c9914b21e2d43"
                },
                {
                  "y": 450,
                  "x": 320,
                  "u": "https://preview.redd.it/sjl6pg2br8va1.png?width=320&amp;crop=smart&amp;auto=webp&amp;v=enabled&amp;s=73241dcd359565035a860f68ab4a542902f7274f"
                }
              ],
              "s": {
                "y": 720,
                "x": 512,
                "u": "https://preview.redd.it/sjl6pg2br8va1.png?width=512&amp;format=png&amp;auto=webp&amp;v=enabled&amp;s=cc745b9993e3cf9a74386b19160c02e3584af2f0"
              },
              "id": "sjl6pg2br8va1"
            },
            "qqh0vvo8r8va1": {
              "status": "valid",
              "e": "Image",
              "m": "image/png",
              "o": [
                {
                  "y": 512,
                  "x": 512,
                  "u": "https://preview.redd.it/qqh0vvo8r8va1.png?width=320&amp;blur=32&amp;format=pjpg&amp;auto=webp&amp;v=enabled&amp;s=73b2562c4ae30bf68503768f4cd887fdda264596"
                }
              ],
              "p": [
                {
                  "y": 108,
                  "x": 108,
                  "u": "https://preview.redd.it/qqh0vvo8r8va1.png?width=108&amp;crop=smart&amp;auto=webp&amp;v=enabled&amp;s=dc7d615fed5ce989a419d8eed3f504f722e4a985"
                },
                {
                  "y": 216,
                  "x": 216,
                  "u": "https://preview.redd.it/qqh0vvo8r8va1.png?width=216&amp;crop=smart&amp;auto=webp&amp;v=enabled&amp;s=8374894c71fab8435567493ddc097f472808fbb1"
                },
                {
                  "y": 320,
                  "x": 320,
                  "u": "https://preview.redd.it/qqh0vvo8r8va1.png?width=320&amp;crop=smart&amp;auto=webp&amp;v=enabled&amp;s=19fd5e9234492623c032d3b56247268ad09df3ce"
                }
              ],
              "s": {
                "y": 512,
                "x": 512,
                "u": "https://preview.redd.it/qqh0vvo8r8va1.png?width=512&amp;format=png&amp;auto=webp&amp;v=enabled&amp;s=c6a495f8d338b691cd3d27d852babed61e3c99e1"
              },
              "id": "qqh0vvo8r8va1"
            },
            "boml08nsr8va1": {
              "status": "valid",
              "e": "Image",
              "m": "image/jpg",
              "o": [
                {
                  "y": 3024,
                  "x": 4032,
                  "u": "https://preview.redd.it/boml08nsr8va1.jpg?width=1080&amp;blur=40&amp;format=pjpg&amp;auto=webp&amp;v=enabled&amp;s=bd469b600a49b189c00b7844ee12a01696d5eede"
                }
              ],
              "p": [
                {
                  "y": 81,
                  "x": 108,
                  "u": "https://preview.redd.it/boml08nsr8va1.jpg?width=108&amp;crop=smart&amp;auto=webp&amp;v=enabled&amp;s=0b8d56c51246ae355093450d4865faf8af3be98f"
                },
                {
                  "y": 162,
                  "x": 216,
                  "u": "https://preview.redd.it/boml08nsr8va1.jpg?width=216&amp;crop=smart&amp;auto=webp&amp;v=enabled&amp;s=e0a60ef3615851d4bae8844b787f917d8335232f"
                },
                {
                  "y": 240,
                  "x": 320,
                  "u": "https://preview.redd.it/boml08nsr8va1.jpg?width=320&amp;crop=smart&amp;auto=webp&amp;v=enabled&amp;s=4ef7a59e0cd03335ce0db80859c1ea6c22ba4574"
                },
                {
                  "y": 480,
                  "x": 640,
                  "u": "https://preview.redd.it/boml08nsr8va1.jpg?width=640&amp;crop=smart&amp;auto=webp&amp;v=enabled&amp;s=12a66827be212f532a4d63c4ccfae4202eb8c95c"
                },
                {
                  "y": 720,
                  "x": 960,
                  "u": "https://preview.redd.it/boml08nsr8va1.jpg?width=960&amp;crop=smart&amp;auto=webp&amp;v=enabled&amp;s=346d51b5c370cec019431bbea82b25ddf2439c64"
                },
                {
                  "y": 810,
                  "x": 1080,
                  "u": "https://preview.redd.it/boml08nsr8va1.jpg?width=1080&amp;crop=smart&amp;auto=webp&amp;v=enabled&amp;s=9f4602ffc2f8a35c9d2430b24bfc91e35b3efe2a"
                }
              ],
              "s": {
                "y": 3024,
                "x": 4032,
                "u": "https://preview.redd.it/boml08nsr8va1.jpg?width=4032&amp;format=pjpg&amp;auto=webp&amp;v=enabled&amp;s=65d904d884c5d08d998883ccf63d0e061ea95cc7"
              },
              "id": "boml08nsr8va1"
            },
            "k22e91rtr8va1": {
              "status": "valid",
              "e": "Image",
              "m": "image/jpg",
              "o": [
                {
                  "y": 3024,
                  "x": 4032,
                  "u": "https://preview.redd.it/k22e91rtr8va1.jpg?width=1080&amp;blur=40&amp;format=pjpg&amp;auto=webp&amp;v=enabled&amp;s=767f658658cc9f38d5a2f94962b8cfb8696526c3"
                }
              ],
              "p": [
                {
                  "y": 81,
                  "x": 108,
                  "u": "https://preview.redd.it/k22e91rtr8va1.jpg?width=108&amp;crop=smart&amp;auto=webp&amp;v=enabled&amp;s=2d866ed6af4e007a748ea4f895c3c0d2d70e5d97"
                },
                {
                  "y": 162,
                  "x": 216,
                  "u": "https://preview.redd.it/k22e91rtr8va1.jpg?width=216&amp;crop=smart&amp;auto=webp&amp;v=enabled&amp;s=d77d0c2a2a4bc1cd0b6f141ea3f25f3b0d6cddab"
                },
                {
                  "y": 240,
                  "x": 320,
                  "u": "https://preview.redd.it/k22e91rtr8va1.jpg?width=320&amp;crop=smart&amp;auto=webp&amp;v=enabled&amp;s=8edf402547b44f4d9b3cb7e8da5db5dbd490acf5"
                },
                {
                  "y": 480,
                  "x": 640,
                  "u": "https://preview.redd.it/k22e91rtr8va1.jpg?width=640&amp;crop=smart&amp;auto=webp&amp;v=enabled&amp;s=a1a1e95c7582b770a34781dc9ed042e58f882f05"
                },
                {
                  "y": 720,
                  "x": 960,
                  "u": "https://preview.redd.it/k22e91rtr8va1.jpg?width=960&amp;crop=smart&amp;auto=webp&amp;v=enabled&amp;s=9278df0d5486dfa091bb74e9b06dda436617cd57"
                },
                {
                  "y": 810,
                  "x": 1080,
                  "u": "https://preview.redd.it/k22e91rtr8va1.jpg?width=1080&amp;crop=smart&amp;auto=webp&amp;v=enabled&amp;s=417e12f414d0c0b119c499df2be6622c4e911385"
                }
              ],
              "s": {
                "y": 3024,
                "x": 4032,
                "u": "https://preview.redd.it/k22e91rtr8va1.jpg?width=4032&amp;format=pjpg&amp;auto=webp&amp;v=enabled&amp;s=5ed15b60911ae862be146243d1a2a13b15fea5f9"
              },
              "id": "k22e91rtr8va1"
            }
          },
          "hide_score": false,
          "quarantine": false,
          "link_flair_text_color": "dark",
          "upvote_ratio": 1.0,
          "ignore_reports": false,
          "ups": 1,
          "domain": "reddit.com",
          "media_embed": {},
          "thumbnail_width": 140,
          "author_flair_template_id": null,
          "is_original_content": false,
          "user_reports": [],
          "secure_media": null,
          "is_reddit_media_domain": false,
          "is_meta": false,
          "category": null,
          "secure_media_embed": {},
          "gallery_data": {
            "items": [
              {
                "caption": "Gatto verde",
                "media_id": "qqh0vvo8r8va1",
                "id": 266156334
              },
              { "media_id": "sjl6pg2br8va1", "id": 266156336 },
              {
                "caption": "Spiaggia",
                "media_id": "boml08nsr8va1",
                "id": 266156337
              },
              {
                "caption": "Torre di Pisa",
                "media_id": "k22e91rtr8va1",
                "id": 266156338
              }
            ]
          },
          "link_flair_text": null,
          "can_mod_post": true,
          "score": 1,
          "approved_by": null,
          "is_created_from_ads_ui": false,
          "author_premium": false,
          "thumbnail": "nsfw",
          "edited": false,
          "author_flair_css_class": null,
          "author_flair_richtext": [],
          "gildings": {},
          "content_categories": null,
          "is_self": false,
          "mod_note": null,
          "created": 1682084711.0,
          "link_flair_type": "text",
          "wls": null,
          "removed_by_category": null,
          "banned_by": null,
          "author_flair_type": "text",
          "total_awards_received": 0,
          "allow_live_comments": false,
          "selftext_html": null,
          "likes": true,
          "suggested_sort": null,
          "banned_at_utc": null,
          "url_overridden_by_dest": "https://www.reddit.com/gallery/12u28fd",
          "view_count": null,
          "archived": false,
          "no_follow": false,
          "spam": false,
          "is_crosspostable": false,
          "pinned": false,
          "over_18": true,
          "all_awardings": [],
          "awarders": [],
          "media_only": false,
          "can_gild": false,
          "removed": false,
          "spoiler": false,
          "locked": false,
          "author_flair_text": null,
          "treatment_tags": [],
          "rte_mode": "markdown",
          "visited": false,
          "removed_by": null,
          "subreddit_type": "private",
          "distinguished": null,
          "subreddit_id": "t5_89iy4l",
          "author_is_blocked": false,
          "mod_reason_by": null,
          "num_reports": 0,
          "removal_reason": null,
          "link_flair_background_color": "",
          "id": "12u28fd",
          "is_robot_indexable": true,
          "report_reasons": [],
          "author": "Francy5615",
          "discussion_type": null,
          "num_comments": 0,
          "send_replies": true,
          "whitelist_status": null,
          "contest_mode": false,
          "mod_reports": [],
          "author_patreon_flair": false,
          "approved": false,
          "author_flair_text_color": null,
          "permalink": "/r/oakforreddit/comments/12u28fd/test_galleria_nsfw/",
          "parent_whitelist_status": null,
          "stickied": false,
          "url": "https://www.reddit.com/gallery/12u28fd",
          "subreddit_subscribers": 1,
          "created_utc": 1682084711.0,
          "num_crossposts": 0,
          "media": null,
          "is_video": false
        }
      }
    """
    
    static var postData: [String : Any] = {
        do {
            return try JSONSerialization.jsonObject(with: postJson.data(using: .utf8)!, options: []) as! [String : Any]
        }
        catch {
            fatalError("Error parsing json: \(error)")
        }
        
    }()
    
    static var post: Post = {
        Thing.build(from: postData)
    }()
    
    
}
