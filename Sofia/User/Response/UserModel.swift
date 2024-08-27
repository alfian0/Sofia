//
//  UserModel.swift
//  Sofia
//
//  Created by alfian on 09/08/24.
//

import Foundation

// MARK: - UserModel

struct UserModel: Codable {
  let data: DataClass?

  // MARK: - DataClass

  struct DataClass: Codable {
    let id, email, timezone: String?
    let timeout: Int?
    let writesOnly: Bool?
    let createdAt: String?
    let colorScheme: String?
    let photo: String?
//    let twitterUsername, website: NSNull?
    let plan: String?
    let weekdayStart: Int?
//    let linkedinUsername, githubUsername: NSNull?
    let languagesUsedPublic: Bool?
//    let shareAllTimeBadge: NSNull?
    let isEmailConfirmed: Bool?
    let displayName: String?
    let modifiedAt: String?
//    let location: NSNull?
    let lastHeartbeatAt: String?
    let lastProject: String?
    let isOnboardingFinished: Bool?
    let publicProfileTimeRange: String?
    let profileURL: String?
    let timeFormatDisplay, dateFormat: String?
    let photoPublic: Bool?
//    let publicEmail: NSNull?
    let isHireable: Bool?
    let invoiceIDFormat: String?
    let hasBasicFeatures, needsPaymentMethod: Bool?
//    let username: NSNull?
    let profileURLEscaped: String?
    let lastPluginName, defaultDashboardRange: String?
    let showMachineNameIP: Bool?
    let durationsSliceBy, lastPlugin: String?
//    let humanReadableWebsite: NSNull?
    let loggedTimePublic, meetingsOverCoding: Bool?
//    let wonderfuldevUsername, timeFormat24Hr, city: NSNull?
    let isEmailPublic: Bool?
//    let shareLastYearDays: NSNull?
    let hasPremiumFeatures: Bool?
//    let bio, lastBranch, fullName: NSNull?
  }
}
