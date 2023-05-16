//
//  MainInfoView.swift
//  WeatherAppDemo
//
//  Created by Davin Henrik on 5/15/23.
//

import SwiftUI

struct WeatherView: View {
    @ObservedObject var viewModel: WeatherViewModel
    // format dates as a property using a closure.
    private let dateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, h:mm a"
        return dateFormatter
    }()
    
    // Display formatted date/time and city from properties within the viewModel.
    var mainViews: some View {
        VStack {
            Text(viewModel.getDateTime(info: viewModel.weatherInfo.timezone),
                 formatter: dateFormatter)
            .padding(.bottom, 15)
            Text(viewModel.weatherInfo.cityName ?? "")
                .font(.largeTitle)
        }
        .padding(.bottom, 40)
    }
    
    /* Display the temperature taken from a property in the viewModel and converts it to Fahrenheit.
        Then display the viewModel.weatherInfo.feelsLike property converted as Fahrenheit.
     */
    var tempViews: some View {
        HStack {
            if let temp = viewModel.weatherInfo.temp {
                Text("Real temperature :- " + String(Int((viewModel.convertToF(temp: temp))))
                     + "F")
                .font(.subheadline)
            }
            Spacer()
                .frame(width: 50)
            if let feelsLike = viewModel.weatherInfo.feelsLike {
                Text("but feels like :- " +
                   String(
                    Int(viewModel.convertToF(temp: feelsLike))) +
                    "F")
                .font(.subheadline)
            }
        }
    }
    
    // Layout structure. 
    var body: some View {
        VStack(alignment: .leading) {
            Spacer()
            mainViews
            tempViews
            Spacer()
        }
        .onAppear {
            Task {@MainActor () -> Void in
                await viewModel.loadData()
            }
        }
    }
}

