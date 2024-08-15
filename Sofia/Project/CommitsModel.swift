//
//  CommitsModel.swift
//  Sofia
//
//  Created by alfian on 10/08/24.
//

import Foundation

// MARK: - CommitModelElement

struct CommitsModel: Codable, Identifiable, Hashable {
  func hash(into hasher: inout Hasher) {
    hasher.combine(sha)
  }

  static func == (lhs: CommitsModel, rhs: CommitsModel) -> Bool {
    return lhs.sha == rhs.sha
  }

  var id = UUID().uuidString
  let sha, nodeID: String?
  let commit: Commit?
  let url, htmlUrl, commentsUrl: String?
  let author, committer: CommitModelAuthor?
  let parents: [Parent]?

  // MARK: - CommitModelAuthor

  struct CommitModelAuthor: Codable {
    let login: String?
    let id: Int?
    let nodeID: String?
    let avatarUrl: String?
    let gravatarID: String?
    let url, htmlUrl, followersUrl: String?
    let followingUrl, gistsUrl, starredUrl: String?
    let subscriptionsUrl, organizationsUrl, reposUrl: String?
    let eventsUrl: String?
    let receivedEventsUrl: String?
    let type: String?
    let siteAdmin: Bool?
  }

  // MARK: - Commit

  struct Commit: Codable {
    let author, committer: CommitAuthor?
    let message: String?
    let tree: Tree?
    let url: String?
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
    let sha: String?
    let url: String?
  }

  // MARK: - Verification

  struct Verification: Codable {
    let verified: Bool?
    let reason: String?
    let signature, payload: String?
  }

  // MARK: - Parent

  struct Parent: Codable {
    let sha: String?
    let url, htmlUrl: String?
  }
}
