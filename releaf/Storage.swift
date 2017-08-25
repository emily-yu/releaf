//
//  Storage.swift
//  releaf
//
//  Created by Emily on 5/22/17.
//  Copyright © 2017 Emily. All rights reserved.
//

import Foundation

// Current user's unique string identifier
var userID = "";

// Current post's UID's
var uid = [String]();

// Notification images (ref: RecentActivityController)
var notifImage = [String]();

// Notification text (ref: RecentActivityController)
var notifText = [Int]();

// Notification users (ref: RecentActivityController)
var notifUser = [String]();

// CreatePostController
var postDestination = [String]();

// Full list of group names (ref: JoinController)
var allgroups = [String]();

// Full list of group descriptions (ref: JoinController)
var groupDescription2 = [String]();

// Full list of group member counts (ref: JoinController)
var groupMemberCount = [Int]();

// Indexes of user's posts (ref: MyPostsController)
var myposts = [Int]();

// Text of user's posts (ref: MyPostsController)
var myPostsText = [String]();

// Index of post clicked on (ref: MyPostsController)
var clickedIndex: Int!

// Current Post "Me Too" Reactions (ref: ReactionsController)
var metoo = [String]();

// Current Post "Hugs" Reactions (ref: ReactionsController)
var hugs = [String]();

// Tracking changes in post index while switching posts
var previousIndex: Int = -1;

// List of Reply Prompts (ref: ReplyController)
var replyPrompts = ["Look at the progress you've made.",
                      "What is within your control?",
                      "Would it still matter 5 years later?",
                      "Is your problem actionable?",
                      "Write your personal mission statement.",
                      "What is the smallest step you can take?",
                      "Create a routine to prevent it from happening again.",
                      "Write down when and where you will be solving this problem.",
                      "Create a prototype to test your assumptions.",
                      "Do something in the next hour to answer a question you have.",
                      "Express your emotions to others.",
                      "Who can you collaborate on this?",
                      "Talk to a mentor.",
                      "Name 5 people you admire.",
                      "Build a supportive community.",
                      "Explore something new.",
                      "Take 5 minutes to do something you find interesting.",
                      "How can you approach this differently?",
                      "Have a beginner's mindset!",
                      "What are new opportunities?",
                      "What are you grateful for now?",
                      "Take 3 deep breaths.",
                      "Look at what is going on with kindness.",
                      "What do you value in this experience?",
                      "What have you learned in this experience?"]

// Replies to PostScroller post (ref: PostScrollerController)
var replies = [String]();

// Number of likes on PostScroller reply (ref: PostScrollerController)
var leaves = [Int](); // store likes for replies to post

// Temporary checking arrays for "Hug" reacts
var checkhugs = [String]();

// Temporary checking arrays for "Me Too" reacts
var checkmetoos = [String]();

// Current post index on the post scroller
var currentIndex = 0

// User's groups (ref: ProfileController)
var userGroups = [String](); // the user's groups

// Indexes of user's favorited posts (ref: ProfileController)
var favoritedPosts = [Int](); // favorited posts (me too, hugs, etc.)

// Text of user's favorited posts (ref: ProfileController)
var favoritedPostsText = [String]();

// Name of group that user is currently navigating (ref: GroupDetailsController)
var groupDetailsTitle = "";

// Index of group that user is currently navigating (ref: GroupDetailsController)
var groupPathPost: String!

// Posts in group that user is currently navigating (ref: GroupDetailsController)
var groupPosts = [String]();
