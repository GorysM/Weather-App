//
//  WeatherForcastView.swift
//  CWK2Template
//
//  Created by girish lukka on 29/10/2023.
//

import SwiftUI

struct WeatherForecastView: View {
    @EnvironmentObject var weatherMapViewModel: WeatherMapViewModel

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if let hourlyData = weatherMapViewModel.weatherDataModel?.hourly {

                        ScrollView(.horizontal, showsIndicators: false) {

                            HStack(spacing: 10) {

                                ForEach(hourlyData) { hour in
                                    HourWeatherView(current: hour)
                                        .frame(width: 150, height: 180)
                                        .background(Color.teal)
                                        .cornerRadius(10)
                                        .ignoresSafeArea()
                                        .aspectRatio(contentMode: .fit)
                                        .multilineTextAlignment(.center)
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                        .frame(height: 180)
                        .background(
                            Image("background2")
                                .resizable()
                                .opacity(0.5)
                                .aspectRatio(contentMode: .fill)
                                .ignoresSafeArea()
                        )
                    }
                    Divider()
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                    VStack {
                        List {
                            ForEach(weatherMapViewModel.weatherDataModel?.daily ?? []) { day in
                                DailyWeatherView(day: day)
                                    .background(
                                        Image("background")
                                            .resizable()
                                            .frame(width: 600, height: 100)
                                            .opacity(0.2)
                                            .ignoresSafeArea()
                                    )
                            }
                        }
                        .listStyle(GroupedListStyle())
                        .frame(height: 500)
                    }
                }
                .padding(.horizontal, 16)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        Image(systemName: "sun.min.fill")
                        VStack {
                            Text("Weather Forecast for \(weatherMapViewModel.city)")
                                .font(.title3)
                                .fontWeight(.bold)
                        }
                    }
                }
            }
        }
        .onAppear {
            Task {
                do {
                    try await weatherMapViewModel.getCoordinatesForCity()
                    try await weatherMapViewModel.loadData(lat: weatherMapViewModel.coordinates?.latitude ?? 0.0, lon: weatherMapViewModel.coordinates?.longitude ?? 0.0)
                } catch {
                    print("Error: \(error)")
                }
            }
        }
    }
}

struct WeatherForecastView_Previews: PreviewProvider {
    static var previews: some View {
        WeatherForecastView()
            .environmentObject(WeatherMapViewModel())
    }
}
