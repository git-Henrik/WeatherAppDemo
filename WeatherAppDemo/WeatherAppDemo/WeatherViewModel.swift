//
//  WeatherViewModel.swift
//  WeatherAppDemo
//
//  Created by Davin Henrik on 5/15/23.
//
// VM for weather data in SwiftUI

import Foundation
import SwiftUI

// Set as ObservableObject; source of truth for other SwiftUI Views.
/*
 userDefaultKey - static; key for storing last city searched.
 weatherInfo - Publishes changes to the property; assessed my the main actor. Represents Weather info from the Data Model.
 Dependancy Injection:
    networkManager & locationService.
    fetch weather data and obtain location info.
 */
class WeatherViewModel: ObservableObject {
    static let userDefaultKey = "cityName"
    
    @MainActor @Published var weatherInfo = WeatherInfo()

    private let networkManager: NetworkManagerProtocol
    private let locationService: LocationServiceProtocol
    
    init(networkManager: NetworkManagerProtocol,
         locationService: LocationServiceProtocol) {
        self.networkManager = networkManager
        self.locationService = locationService
    }
    
    // async method fetching weather info by different paths.
    // Fetch by Specified city, userDefaults cityName, or current location.
    
    func loadData() async {
        var response: Response?
        do {
            if let cityName = await weatherInfo.cityName {
                response = try? await networkManager.fetchWeatherInfoByName(city: cityName,
                                                                            country: nil, state: nil)
            }else if let cityName = UserDefaults.standard.object(forKey: Self.userDefaultKey) as? String {
                response = try? await networkManager.fetchWeatherInfoByName(city: cityName ,
                                                                            country: nil, state: nil)
            } else if let position = locationService.getLocation() {
                response = try await networkManager.fetchWeatherInfoByPosition(lat: position.lat, lon: position.lon)
            }
        } catch (let error) {
            print(error.localizedDescription)
        }
        if let response = response {
            await saveResponseToinfo(response)
            await saveLastCityName()
        }
    }
     
    @MainActor private func saveLastCityName()  {
        if let cityName = self.weatherInfo.cityName {
            UserDefaults.standard.set(cityName, forKey: Self.userDefaultKey)
        }
    }
    
    // Last searched City saved to User Defaults.
    @MainActor private func saveResponseToinfo(_ response: Response) {
        self.weatherInfo.cityName = response.name
        self.weatherInfo.lat = response.coord?.lat
        self.weatherInfo.lon = response.coord?.lon
        self.weatherInfo.temp = response.main?.temp
        self.weatherInfo.feelsLike = response.main?.feels_like
        self.weatherInfo.main = response.weather?.first?.main
        self.weatherInfo.desc = response.weather?.description
        self.weatherInfo.windSpeed = response.wind?.speed
        self.weatherInfo.windDegree = response.wind?.deg
        self.weatherInfo.pressure = response.main?.pressure
        self.weatherInfo.humidity = response.main?.humidity
        self.weatherInfo.visibility = response.visibility
        self.weatherInfo.timezone = response.timezone
        
    }
    
    // Takes param representing the timezone offset; returns a Date object adjusted by that offset.
    // if Nil; return current date.
    func getDateTime(info: Double?) -> Date {
        let value = Date()
        if let timezone = info {
            return value+timezone
        } else {
            return value
        }
    }
    
    // method converting fetched temp data from Kelvin to Fahrenheit. 
    func convertToF(temp: Double) -> Double {
        let value = temp - 273.15
        return (value * 9) / 5
    }
}
