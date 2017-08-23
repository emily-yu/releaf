//
//  Storage.swift
//  releaf
//
//  Created by Emily on 5/22/17.
//  Copyright © 2017 Emily. All rights reserved.
//

import Foundation

// store all global variables

// AppDelegate
var uid = [String]();
var userID = "";

// RecentActivityController
var notifImage = [String]();
var notifText = [Int]();
var notifUser = [String]();

// CreatePostController
var postDestination = [String]();

// GroupController
var allgroups = [String](); // group names to join in JoinController
var groupDescription2 = [String](); // description of groups in JoinController
var groupMemberCount = [Int](); // group member counts

// MyPostsController
var myposts = [Int](); // indexes of your posts - used to retrieve
var myPostsText = [String](); // text of your posts
var clickedIndex: Int! // track the index of the post you're viewing

// ReactionsController
var metoo = [String](); // me too reaction
var hugs = [String](); // hugs reaction
var previousIndex: Int = -1 // track whether the index has changed when switching posts

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

// ProfileController
// User's groups (ref: ProfileController)
var userGroups = [String](); // the user's groups

// Indexes of user's favorited posts (ref: ProfileController)
var favoritedPosts = [Int](); // favorited posts (me too, hugs, etc.)

// Text of user's favorited posts (ref: ProfileController)
var favoritedPostsText = [String]();

// GroupDetailsController
var groupDetailsTitle = "";
var groupPathPost: String! // the group to post the new post to
var groupPosts = [String](); // the group's posts
