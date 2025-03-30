//
//  MockData.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 16/03/2025.
//

import Foundation

let mockAuthResponse = AuthResponse(value: AuthModel(token: "123456", validInMins: 20, validUntilUTC: "2025-03-26T01:29:38.946042Z"), failureReason: nil, isSuccess: true)
let mockAuthResponseWithFailureReason = AuthResponse(value: nil, failureReason: "Server response error message", isSuccess: false)

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
