//
//  Constant.swift
//  RunnerApp
//
//  Created by Steven Prescott on 9/28/15.
//  Copyright (c) 2015 Steven Prescott. All rights reserved.
//

import Foundation


let baseUrl = "http://oips.org/runnerapp/api/web/v1/" // developmentURL
//let baseUrl = "http://status.keyss.in/app/api/web/v1/" // liveURL

//LoginApi
 //http://oips.org/runnerapp/api/web/v1/users/login?fields=email_id,access_token
//http://oips.org/runnerapp/api/web/v1/runners

//http://oips.org/runnerapp/api/web/v1/users

//http://oips.org/runnerapp/api/web/v1/runners/remove?id=3
//http://oips.org/runnerapp/api/web/v1/users/remove?id=4

//http://oips.org/runnerapp/api/web/v1/runners/edit?id=2

//http://oips.org/runnerapp/api/web/v1/users/remove?id=10


//http://oips.org/runnerapp/api/web/v1/users/updateprofile?id=10

//http://oips.org/runnerapp/api/web/v1/runners

//http://oips.org/runnerapp/api/web/v1/runs


//http://oips.org/runnerapp/api/web/v1/runs


var LoginApi = String(baseUrl + "users/login?")
var RunnerListApi = String(baseUrl + "users")
var SignUpApi = String(baseUrl + "users")
var RemoveRunnerApi = String(baseUrl + "users/remove?")
var EditRunnerApi = String(baseUrl + "users/updateprofile?")
var RunStatApi = String(baseUrl + "runs")
var AddRunApi = String(baseUrl + "runs")