//
//  CommitModel.swift
//  Sofia
//
//  Created by alfian on 12/08/24.
//

import Foundation

// MARK: - CommitModel
struct CommitModel: Codable {
  let url: String?
  let sha, nodeID: String?
  let htmlURL, commentsURL: String?
  let commit: Commit?
  let author, committer: CommitModelAuthor?
  let parents: [Tree]?
  let stats: Stats?
  let files: [File]?
  
  // MARK: - CommitModelAuthor
  struct CommitModelAuthor: Codable {
      let login: String?
      let id: Int?
      let nodeID: String?
      let avatarURL: String?
      let gravatarID: String?
      let url, htmlURL, followersURL: String?
      let followingURL, gistsURL, starredURL: String?
      let subscriptionsURL, organizationsURL, reposURL: String?
      let eventsURL: String?
      let receivedEventsURL: String?
      let type: String?
      let siteAdmin: Bool?
  }

  // MARK: - Commit
  struct Commit: Codable {
      let url: String?
      let author, committer: CommitAuthor?
      let message: String?
      let tree: Tree?
      let commentCount: Int?
      let verification: Verification?
  }

  // MARK: - CommitAuthor
  struct CommitAuthor: Codable {
      let name, email: String?
      let date: String?
  }

  // MARK: - Tree
  struct Tree: Codable {
      let url: String?
      let sha: String?
  }

  // MARK: - Verification
  struct Verification: Codable {
      let verified: Bool?
      let reason: String?
      let signature, payload: String?
  }

  // MARK: - File
  struct File: Codable {
      let filename: String?
      let additions, deletions, changes: Int?
      let status: String?
      let rawURL, blobURL: String?
      let patch: String?
  }

  // MARK: - Stats
  struct Stats: Codable {
      let additions, deletions, total: Int?
  }
}
