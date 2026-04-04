//
//  MockData.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 16/03/2025.
//

import Foundation

let mockUser1 = UserModel(
    id: 1,
    username: "test_username1",
    password: "abcdefg123456",
    displayName: "Test User 1",
    email: "test_username1@example.com",
    emailVerified: true,
    disabled: false,
    photoUrl: "123456abcdefg",
    firebaseUid: "firebase_uid_1",
    createdAt: "2024-03-05T12:06:20.1476085Z",
    updatedAt: "2024-03-05T12:06:20.1476085Z",
    lastLoginAt: "2024-03-06T08:30:00.0000000Z",
    signInProvider: "password",
    currentWatchRelationshipId: nil,
    role: "User",
)

let mockUser2 = UserModel(
    id: 2,
    username: "test_username2",
    password: "abcdefg123456",
    displayName: "Test Admin 2",
    email: "test_username2@example.com",
    emailVerified: true,
    disabled: false,
    photoUrl: "123456abcdefg",
    firebaseUid: "firebase_uid_2",
    createdAt: "2024-03-05T12:06:20.1476085Z",
    updatedAt: "2024-03-05T12:06:20.1476085Z",
    lastLoginAt: "2024-03-07T10:45:00.0000000Z",
    signInProvider: "google.com",
    currentWatchRelationshipId: 202,
    role: "Administrator",
)

let mockUser3 = UserModel(
    id: 3,
    username: "test_username3",
    password: "abcdefg123456",
    displayName: "Test User 3",
    email: "test_username3@example.com",
    emailVerified: false,
    disabled: true,
    photoUrl: "123456abcdefg",
    firebaseUid: "firebase_uid_3",
    createdAt: "2024-03-05T12:06:20.1476085Z",
    updatedAt: "2024-03-05T12:06:20.1476085Z",
    lastLoginAt: "2024-03-08T09:15:00.0000000Z",
    signInProvider: "apple.com",
    currentWatchRelationshipId: nil,
    role: "User",
)

let mockUserResponse1 = UserResponse(value: mockUser1, failureReason: nil, isSuccess: true)
let mockUserResponse2 = UserResponse(value: mockUser2, failureReason: nil, isSuccess: true)
let mockUserResponse3 = UserResponse(value: mockUser3, failureReason: nil, isSuccess: true)
let mockUserResponseWithFailureReason = UserResponse(value: nil, failureReason: "Server response error message", isSuccess: false)
let mockUserExistResponseTrue = UserExistResponse(value: true, failureReason: nil, isSuccess: true)
let mockUserExistResponseFalse = UserExistResponse(value: false, failureReason: nil, isSuccess: true)
let mockUserExistResponseWithFailureReason = UserExistResponse(value: nil, failureReason: "Server response error message", isSuccess: false)
let mockUserListResponse = UserListResponse(value: [mockUser1, mockUser2], failureReason: nil, isSuccess: true)
let mockUserListResponseWithFailureReason = UserListResponse(value: nil, failureReason: "Server response error message", isSuccess: false)

let mockInvitation1 = InvitationModel(
    id: 101,
    ownerUserId: mockUser2.id,
    inviteeEmail: mockUser1.email,
    inviteeUserId: mockUser1.id,
    status: "Pending",
    message: "Please accept tracking access for family safety.",
    expiresAt: "2026-04-01T09:00:00.0000000Z",
    acceptedAt: nil,
    declinedAt: nil,
    revokedAt: nil,
    createdAt: "2026-03-26T09:00:00.0000000Z",
    updatedAt: "2026-03-26T09:00:00.0000000Z",
    ownerUser: mockUser2,
    inviteeUser: mockUser1
)

let mockInvitation2 = InvitationModel(
    id: 102,
    ownerUserId: mockUser2.id,
    inviteeEmail: mockUser3.email,
    inviteeUserId: mockUser3.id,
    status: "Accepted",
    message: "Accepted invitation for daily watch access.",
    expiresAt: "2026-04-05T18:30:00.0000000Z",
    acceptedAt: "2026-03-27T10:15:00.0000000Z",
    declinedAt: nil,
    revokedAt: nil,
    createdAt: "2026-03-25T18:30:00.0000000Z",
    updatedAt: "2026-03-27T10:15:00.0000000Z",
    ownerUser: mockUser2,
    inviteeUser: mockUser3
)

let mockInvitation3 = InvitationModel(
    id: 103,
    ownerUserId: mockUser1.id,
    inviteeEmail: "pending_parent@example.com",
    inviteeUserId: nil,
    status: "Sent",
    message: "Invitation sent and waiting for account registration.",
    expiresAt: "2026-04-10T12:00:00.0000000Z",
    acceptedAt: nil,
    declinedAt: nil,
    revokedAt: nil,
    createdAt: "2026-03-28T12:00:00.0000000Z",
    updatedAt: "2026-03-28T12:00:00.0000000Z",
    ownerUser: mockUser1,
    inviteeUser: nil
)

let mockInvitationList: [InvitationModel] = [
    mockInvitation1,
    mockInvitation2,
    mockInvitation3
]

let mockInvitationListResponse = InvitationListResponse(value: mockInvitationList, failureReason: nil, isSuccess: true)
let mockInvitationListResponseWithFailureReason = InvitationListResponse(value: nil, failureReason: "Server response error message", isSuccess: false)

let mockWatchRelationship1 = WatchRelationshipModel(
    id: 201,
    ownerUserId: mockUser2.id,
    watchedUserId: mockUser1.id,
    invitationId: mockInvitation1.id,
    status: "Active",
    activatedAt: "2026-03-27T08:00:00.0000000Z",
    revokedAt: nil,
    createdAt: "2026-03-27T08:00:00.0000000Z",
    updatedAt: "2026-03-27T08:00:00.0000000Z",
    watchedUser: mockUser1
)

let mockWatchRelationship2 = WatchRelationshipModel(
    id: 202,
    ownerUserId: mockUser2.id,
    watchedUserId: mockUser3.id,
    invitationId: mockInvitation2.id,
    status: "Paused",
    activatedAt: "2026-03-28T07:45:00.0000000Z",
    revokedAt: nil,
    createdAt: "2026-03-28T07:45:00.0000000Z",
    updatedAt: "2026-03-29T20:10:00.0000000Z",
    watchedUser: mockUser3
)

let mockWatchRelationship3 = WatchRelationshipModel(
    id: 203,
    ownerUserId: mockUser1.id,
    watchedUserId: 4,
    invitationId: nil,
    status: "Pending",
    activatedAt: nil,
    revokedAt: nil,
    createdAt: "2026-03-29T14:20:00.0000000Z",
    updatedAt: "2026-03-29T14:20:00.0000000Z",
    watchedUser: UserModel(
        id: 4,
        username: "test_username4",
        password: nil,
        displayName: "Test User 4",
        email: "test_username4@example.com",
        emailVerified: true,
        disabled: false,
        photoUrl: "photo_url_4",
        firebaseUid: "firebase_uid_4",
        createdAt: "2026-03-20T11:00:00.0000000Z",
        updatedAt: "2026-03-29T14:20:00.0000000Z",
        lastLoginAt: "2026-03-29T08:10:00.0000000Z",
        signInProvider: "password",
        role: "User"
    )
)

let mockWatchRelationshipList: [WatchRelationshipModel] = [
    mockWatchRelationship1,
    mockWatchRelationship2,
    mockWatchRelationship3
]

let mockWatchRelationshipListResponse = WatchRelationshipListResponse(value: mockWatchRelationshipList, failureReason: nil, isSuccess: true)
let mockWatchRelationshipListResponseWithFailureReason = WatchRelationshipListResponse(value: nil, failureReason: "Server response error message", isSuccess: false)

let mockAuth1 = AuthModel(
    accessToken: "123456",
    accessTokenExpiresAt: "2025-03-26T01:29:38.946042Z",
    expiresIn: 20,
    refreshToken: "refresh_token_1",
    user: mockUser1
)
let mockAuth2 = AuthModel(
    accessToken: "mock_token",
    accessTokenExpiresAt: "2025-03-26T01:29:38.946042Z",
    expiresIn: 2000,
    refreshToken: "refresh_token_2",
    user: mockUser2
)
let mockAuthResponse1 = AuthResponse(value: mockAuth1, failureReason: nil, isSuccess: true)
let mockAuthResponse2 = AuthResponse(value: mockAuth2, failureReason: nil, isSuccess: true)
let mockAuthResponseWithFailureReason = AuthResponse(value: nil, failureReason: "Server response error message", isSuccess: false)

@MainActor
let mockSessionManager = SessionManager(
    keyChainUtil: KeyChainUtil(bundleId: "com.example.TrackerParent"),
    userDefaults: UserDefaults(suiteName: "au.com.matrixthoughts.TrackerParent.mock") ?? .standard
)

let mockSetting1 = SettingModel(
    id: 1,
    userName: "test_username",
    collectionFrequency: 10,
    pushFrequency: 10,
    distanceFilter: 50,
    startTime: "11:10:00",
    endTime: "11:45:00",
    accuracy: "High"
)

let mockSetting2 = SettingModel(
    id: 2,
    userName: "test_username",
    collectionFrequency: 10,
    pushFrequency: 10,
    distanceFilter: 50,
    startTime: "14:00:00",
    endTime: "16:30:00",
    accuracy: "High"
)

let mockAllSettingsResponse = AllSettingsResponse(value: [mockSetting1, mockSetting2], failureReason: nil, isSuccess: true)
let mockAllSettingsResponseWithFailureReason = AllSettingsResponse(value: nil, failureReason: "Server response error message", isSuccess: false)
let mockSettingResponse = SettingResponse(value: mockSetting1, failureReason: nil, isSuccess: true)
let mockSettingResponseWithFailureReason = SettingResponse(value: nil, failureReason: "Server response error message", isSuccess: false)
let mockDeleteSettingResponse = DeleteSettingResponse(value: true, failureReason: nil, isSuccess: true)
let mockDeleteSettingResponseWithFailureReason = DeleteSettingResponse(value: nil, failureReason: "Server response error message", isSuccess: false)

let locationModel1 = LocationModel(
    id: 964,
    userName: "armstrong.liu@matrixthoughts.com.au",
    latitude: "-36.7915521",
    longitude: "174.757091",
    speed: "-1",
    direction: "-1",
    dateTimeOcurred: "2025-03-08T02:23:45.348Z",
    createdDateTime: "2025-03-11T10:00:16.2244296Z"
)

let locationModel2 = LocationModel(
    id: 965,
    userName: "armstrong.liu@matrixthoughts.com.au",
    latitude: "-36.7915512",
    longitude: "174.757102",
    speed: "-1",
    direction: "-1",
    dateTimeOcurred: "2025-03-08T02:44:02.513Z",
    createdDateTime: "2025-03-11T10:00:16.2244779Z"
)

let locationModel3 = LocationModel(
    id: 966,
    userName: "armstrong.liu@matrixthoughts.com.au",
    latitude: "-36.7914783",
    longitude: "174.7570104",
    speed: "-1",
    direction: "-1",
    dateTimeOcurred: "2025-03-08T04:28:09.461Z",
    createdDateTime: "2025-03-11T10:00:16.2244794Z"
)

let locationModel4 = LocationModel(
    id: 967,
    userName: "armstrong.liu@matrixthoughts.com.au",
    latitude: "-36.7914979",
    longitude: "174.7570521",
    speed: "-1",
    direction: "-1",
    dateTimeOcurred: "2025-03-08T04:30:13.53Z",
    createdDateTime: "2025-03-11T10:00:16.2244806Z"
)

let locationModel5 = LocationModel(
    id: 968,
    userName: "armstrong.liu@matrixthoughts.com.au",
    latitude: "-36.7914084",
    longitude: "174.7570362",
    speed: "3.2",
    direction: "342.47",
    dateTimeOcurred: "2025-03-08T04:31:34.029Z",
    createdDateTime: "2025-03-11T10:00:16.2244825Z"
)

let locationModel6 = LocationModel(
    id: 969,
    userName: "armstrong.liu@matrixthoughts.com.au",
    latitude: "-36.7915477",
    longitude: "174.7570743",
    speed: "0.25",
    direction: "288.35",
    dateTimeOcurred: "2025-03-08T04:35:11.014Z",
    createdDateTime: "2025-03-11T10:00:16.224484Z"
)

let locationModel7 = LocationModel(
    id: 970,
    userName: "armstrong.liu@matrixthoughts.com.au",
    latitude: "-36.7915547",
    longitude: "174.7570934",
    speed: "-1",
    direction: "-1",
    dateTimeOcurred: "2025-03-08T04:41:27.714Z",
    createdDateTime: "2025-03-11T10:00:16.2244857Z"
)

let locationModel8 = LocationModel(
    id: 971,
    userName: "armstrong.liu@matrixthoughts.com.au",
    latitude: "-36.791456",
    longitude: "174.7569794",
    speed: "2.24",
    direction: "318.49",
    dateTimeOcurred: "2025-03-08T04:41:47.829Z",
    createdDateTime: "2025-03-11T10:00:16.2244901Z"
)

let locationModel9 = LocationModel(
    id: 972,
    userName: "armstrong.liu@matrixthoughts.com.au",
    latitude: "-36.7915453",
    longitude: "174.7570768",
    speed: "2.28",
    direction: "138.86",
    dateTimeOcurred: "2025-03-08T04:41:52.886Z",
    createdDateTime: "2025-03-11T10:00:16.2244915Z"
)

let locationModel10 = LocationModel(
    id: 973,
    userName: "armstrong.liu@matrixthoughts.com.au",
    latitude: "-36.7913941",
    longitude: "174.7569808",
    speed: "3.8",
    direction: "327.7",
    dateTimeOcurred: "2025-03-08T04:45:34.056Z",
    createdDateTime: "2025-03-11T10:00:16.2244929Z"
)

let locationModel11 = LocationModel(
    id: 974,
    userName: "armstrong.liu@matrixthoughts.com.au",
    latitude: "-36.7915644",
    longitude: "174.7570912",
    speed: "0.64",
    direction: "183.68",
    dateTimeOcurred: "2025-03-08T04:45:44.695Z",
    createdDateTime: "2025-03-11T10:00:16.2244942Z"
)

let locationModel12 = LocationModel(
    id: 975,
    userName: "armstrong.liu@matrixthoughts.com.au",
    latitude: "-36.7914512",
    longitude: "174.7569624",
    speed: "3.18",
    direction: "316.58",
    dateTimeOcurred: "2025-03-08T04:46:00.361Z",
    createdDateTime: "2025-03-11T10:00:16.2244955Z"
)

let locationModel13 = LocationModel(
    id: 976,
    userName: "armstrong.liu@matrixthoughts.com.au",
    latitude: "-36.7915636",
    longitude: "174.757098",
    speed: "0.1",
    direction: "134.71",
    dateTimeOcurred: "2025-03-08T04:46:26.055Z",
    createdDateTime: "2025-03-11T10:00:16.2244968Z"
)

let locationModel14 = LocationModel(
    id: 977,
    userName: "armstrong.liu@matrixthoughts.com.au",
    latitude: "-36.7915286",
    longitude: "174.7570682",
    speed: "-1",
    direction: "-1",
    dateTimeOcurred: "2025-03-08T04:47:28.956Z",
    createdDateTime: "2025-03-11T10:00:16.2244981Z"
)

let locationModel15 = LocationModel(
    id: 978,
    userName: "armstrong.liu@matrixthoughts.com.au",
    latitude: "-36.791428",
    longitude: "174.7569341",
    speed: "3.58",
    direction: "313.18",
    dateTimeOcurred: "2025-03-08T04:49:59.856Z",
    createdDateTime: "2025-03-11T10:00:16.2244994Z"
)

let locationModel16 = LocationModel(
    id: 979,
    userName: "armstrong.liu@matrixthoughts.com.au",
    latitude: "-36.7915562",
    longitude: "174.757097",
    speed: "0.96",
    direction: "138.85",
    dateTimeOcurred: "2025-03-08T04:50:10.448Z",
    createdDateTime: "2025-03-11T10:00:16.2245006Z"
)

let locationModel17 = LocationModel(
    id: 980,
    userName: "armstrong.liu@matrixthoughts.com.au",
    latitude: "-36.7914887",
    longitude: "174.7570205",
    speed: "1.72",
    direction: "319.74",
    dateTimeOcurred: "2025-03-08T04:51:01.321Z",
    createdDateTime: "2025-03-11T10:00:16.2245019Z"
)

let locationModel18 = LocationModel(
    id: 981,
    userName: "armstrong.liu@matrixthoughts.com.au",
    latitude: "-36.7915573",
    longitude: "174.7570973",
    speed: "0.24",
    direction: "124.27",
    dateTimeOcurred: "2025-03-08T04:51:11.384Z",
    createdDateTime: "2025-03-11T10:00:16.2245031Z"
)

let locationModel19 = LocationModel(
    id: 982,
    userName: "armstrong.liu@matrixthoughts.com.au",
    latitude: "-36.7915365",
    longitude: "174.7570979",
    speed: "0.55",
    direction: "28.37",
    dateTimeOcurred: "2025-03-08T04:52:26.8Z",
    createdDateTime: "2025-03-11T10:00:16.2245043Z"
)

let locationModel20 = LocationModel(
    id: 983,
    userName: "armstrong.liu@matrixthoughts.com.au",
    latitude: "-36.791555",
    longitude: "174.7570963",
    speed: "-1",
    direction: "-1",
    dateTimeOcurred: "2025-03-08T04:53:30.39Z",
    createdDateTime: "2025-03-11T10:00:16.2245055Z"
)

let mockTrack: [LocationModel] = [
    locationModel1,
    locationModel2,
    locationModel3,
    locationModel4,
    locationModel5,
    locationModel6,
    locationModel7,
    locationModel8,
    locationModel9,
    locationModel10,
    locationModel11,
    locationModel12,
    locationModel13,
    locationModel14,
    locationModel15,
    locationModel16,
    locationModel17,
    locationModel18,
    locationModel19,
    locationModel20
]

let mockLocationResponse = LocationResponse(value: mockTrack, failureReason: nil, isSuccess: true)
let mockLocationResponseWithFailureReason = LocationResponse(value: nil, failureReason: "Server response error message", isSuccess: false)
