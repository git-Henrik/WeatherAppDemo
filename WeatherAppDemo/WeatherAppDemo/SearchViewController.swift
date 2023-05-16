//
//  SearchViewController.swift
//  WeatherAppDemo
//
//  Created by Davin Henrik on 5/15/23.
//
// Combining UIKit/SwiftUI to create a view controller. 
import UIKit
import SwiftUI

class SearchViewController: UIViewController {
/*
 Properties -
 searchBar: user input
 locationBtn: lazy init; trigger search action
 weatherView: instance; embed SwiftUI WeatherView in UIKit based SearchViewController
 viewModel: instance WeatherViewModel; bus logic/data -> WeatherView
 */
    let searchBar = UISearchBar()
    
    private lazy var locationBtn = {
        let btn = UIButton(type: .system)
        btn.setTitle("Search", for: .normal)
        btn.addTarget(self, action: #selector(searchAction), for: .touchUpInside)
        return btn
    }()
    
    private var weatherView: UIHostingController<WeatherView>?
    private var viewModel: WeatherViewModel?

    // init setupView() and setupUI()
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        setupView()
        setupUI()
    }
    // init WeatherViewModel w/ instances of NetworkManager and WeatherView -> WeatherViewModel to the view.
    private func setupView() {
        let networkManager = NetworkManager()
        let locationService = LocationService()
        viewModel = WeatherViewModel(networkManager: networkManager,
                                         locationService: locationService)
        if let viewModel = viewModel {
            weatherView = UIHostingController(rootView: WeatherView(viewModel: viewModel))
        }
    }
    // Config UI w/ searchBar, location buttons, and layout constraints.
    private func setupUI() {
        view.backgroundColor = .white
        let safeArea = view.safeAreaLayoutGuide
        view.addSubview(searchBar)
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(locationBtn)
        locationBtn.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: safeArea.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            //searchBar.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant:-20)
            locationBtn.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 20),
            locationBtn.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            locationBtn.leadingAnchor.constraint(equalTo: searchBar.trailingAnchor, constant: 20)
            ])
    
        if let weatherView = weatherView {
            view.addSubview(weatherView.view)
            self.addChild(weatherView)
            weatherView.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                weatherView.view.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 20),
                weatherView.view.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
                weatherView.view.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
                weatherView.view.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -20)
            ])
        }
    }
    // Triggered by search btn; set cityName to nil; call loadViewData method -> fetch data.
    @objc func searchAction() {
        self.viewModel?.weatherInfo.cityName = nil
        loadViewData()
    }
    
    private func loadViewData() {
        Task { @MainActor () -> Void in
            await self.viewModel?.loadData()
        }
    }
}
// adopt UISearchBarDelegate Protocol; implement searchBar method. Called when searchBar text changes. 
extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if !searchText.isEmpty {
            self.viewModel?.weatherInfo.cityName = searchText
            loadViewData()
        }
    }
}
