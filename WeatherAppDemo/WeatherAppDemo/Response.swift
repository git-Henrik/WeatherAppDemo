//
//  Response.swift
//  WeatherAppDemo
//
//  Created by Davin Henrik on 5/15/23.
//

// Data Model for the Weather Response.
// Property names will directly reflect the specific data obtained.

import Foundation
import SwiftUI

struct Coord: Codable {
    let lon: Double
    let lat: Double
}

struct Weather: Codable {
    let main: String
    let description: String
    let icon: String
}

struct Main: Codable {
    let temp: Double
    let feels_like: Double
    let pressure: Double
    let humidity: Double
}

struct Wind: Codable {
    let speed: Double
    let deg: Double
}


// Overall Weather Repsonse for desired location.
// Defined as "public" for global use.
public struct Response: Codable {
    let name: String?
    let weather: [Weather]?
    let coord: Coord?
    let main: Main?
    let visibility: Double
    let wind: Wind?
    let timezone: Double
}

struct WeatherInfo {
    var cityName: String?
    var lon: Double?
    var lat: Double?
    var icon: Image?
    var temp: Double?
    var feelsLike: Double?
    var main: String?
    var desc: String?
    var windSpeed: Double?
    var windDegree: Double?
    var pressure: Double?
    var humidity: Double?
    var visibility: Double?
    var timezone: Double?
}
