//
//  GithubUserModel.swift
//  Sofia
//
//  Created by alfian on 15/08/24.
//

import Foundation

struct GithubUserModel: Codable {
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
  let name, company: String?
  let blog: String?
  let location, email: String?
  let hireable: Bool?
  let bio: String?
  let twitterUsername: String?
  let notificationEmail: String?
  let publicRepos, publicGists, followers, following: Int?
  let createdAt, updatedAt: String?
}
