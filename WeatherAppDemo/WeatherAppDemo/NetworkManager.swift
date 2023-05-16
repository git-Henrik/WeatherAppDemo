//
//  NetworkManager.swift
//  WeatherAppDemo
//
//  Created by Davin Henrik on 5/15/23.
//

// Networking layer for fetching Weather info from API.

import Foundation
// Define the Api key
class Api {
    static let key = "c2d2cdfd49dcd8d80c85426f49f5e625"
}

// represent any errors during Api request.
enum NetworkError: Error {
    case fetchError
}


// Protocol defining async api calls.
public protocol NetworkManagerProtocol {
    func fetchWeatherInfoByName(city: String?, country: String? , state: String? ) async throws -> Response?
    func fetchWeatherInfoByPosition(lat: Double, lon: Double ) async throws -> Response?
}


//implementation of protocol.
/*
 fetchWeatherInfoByName...
 Create a URL with user generated city name + Api key.
 Use URLSession.shared.data to fetch data;
 Decode with JSONDecoder to Response Type
 
 fetchWeatherInfoByPosition...
 Create URL from lat/long + Api key.
 Similar process to fetchWeatherInfoByName.
 */
class NetworkManager: NetworkManagerProtocol {
    
    //
    var baseString = "https://api.openweathermap.org/data/2.5/weather?"

    func fetchWeatherInfoByName(city: String? = nil, country: String? = nil, state: String? = nil) async throws -> Response? {
        guard let cityName = city
        else { return nil }
        let urlString = baseString + "q="+cityName+"&appid="+Api.key
        guard let url = URL(string: urlString)
        else{
            throw NetworkError.fetchError
        }
        let (data, _) = try await URLSession.shared.data(from:url)
        return try? JSONDecoder().decode(Response.self, from: data)
    }
    
    func fetchWeatherInfoByPosition(lat: Double, lon: Double) async throws -> Response? {
        let urlString = baseString + "lat=\(lat)&lon=\(lon)" + "&appid="+Api.key
        guard let url = URL(string: urlString)
        else {
            throw NetworkError.fetchError
        }
        let (data, _) = try await URLSession.shared.data(from:url)
        return try? JSONDecoder().decode(Response.self, from: data)
    }
    
}
