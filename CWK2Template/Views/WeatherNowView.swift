//
//  WeatherNowView.swift
//  CWK2Template
//
//  Created by girish lukka on 29/10/2023.
//

import SwiftUI

struct WeatherNowView: View {
    @EnvironmentObject var weatherMapViewModel: WeatherMapViewModel
    @State private var temporaryCity = ""

    var body: some View {
        ZStack {
            Image("sky")
                .resizable()
                .opacity(0.4)
                .ignoresSafeArea()

            VStack {
                HStack {
                    Text("Change Location")

                    TextField("Enter New Location", text: $temporaryCity)
                        .onSubmit {
                            Task {
                                do {
                                    weatherMapViewModel.city = temporaryCity

                                    // Fetch coordinates for the new city
                                    try await weatherMapViewModel.getCoordinatesForCity()

                                    // Fetch weather data for the new location
                                    try await weatherMapViewModel.loadData(lat: weatherMapViewModel.coordinates?.latitude ?? 0.0, lon: weatherMapViewModel.coordinates?.longitude ?? 0.0)
                                    
                                } catch {
                                    print("Error: \(error)")
                                }
                            }
                        }
                }
                .bold()
                .font(.system(size: 20))
                .padding(10)
                .shadow(color: .blue, radius: 10)
                .cornerRadius(10)
                .fixedSize()
                .font(.custom("Arial", size: 26))
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .cornerRadius(15)

                VStack {
                    HStack {
                        Text("Current Location: \(weatherMapViewModel.city)")
                    }
                    .bold()
                    .font(.system(size: 20))
                    .padding(10)
                    .shadow(color: .blue, radius: 10)
                    .cornerRadius(10)
                    .fixedSize()
                    .font(.custom("Arial", size: 26))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .cornerRadius(15)

                    if let timestamp = weatherMapViewModel.weatherDataModel?.current.dt,
                    let timezoneOffset = weatherMapViewModel.weatherDataModel?.timezoneOffset {
                    let localTimestamp = TimeInterval(timestamp) + Double(timezoneOffset)
                    let formattedDate = DateFormatterUtils.formattedDateTime(from:localTimestamp)
                        Text(formattedDate)
                            .padding()
                            .font(.title)
                            .foregroundColor(.black)
                            .shadow(color: .black, radius: 1)

                    }

                    HStack {
                        Spacer()
                        VStack(spacing: 20) {
                            if let weather = weatherMapViewModel.weatherDataModel {
                                AsyncImage (url:URL( string: "https://openweathermap.org/img/wn/\(weather.current.weather[0].icon)@2x.png"))
                                    .frame(width: 15, height: 15)

                                Image("temperature")
                                    .resizable()
                                    .frame(width: 35, height: 35)
                                    .multilineTextAlignment(.leading)
                                Image("humidity")
                                    .resizable()
                                    .frame(width: 35, height: 35)
                                    .multilineTextAlignment(.leading)
                                    .frame(width: 35, height: 35)
                                Image("pressure")
                                    .resizable()
                                    .frame(width: 35, height: 35)
                                    .multilineTextAlignment(.leading)
                                Image("windSpeed")
                                    .resizable()
                                    .frame(width: 35, height: 35)
                                    .multilineTextAlignment(.leading)
                            }
                        }
                        Spacer()

                        VStack(spacing: 25) {
                            if let description = weatherMapViewModel.weatherDataModel?.current.weather[0] {
                                Text("\(description.weatherDescription.rawValue)")
                                    .font(.system(size: 30, weight: .medium))
                            }

                            if let forecast = weatherMapViewModel.weatherDataModel {
                                let wind: Int = Int(forecast.current.windSpeed)
                                Text("Temp: \((Int)(forecast.current.temp))ºC")
                                    .font(.system(size: 25, weight: .medium))
                                    .multilineTextAlignment(.center)
                                Text("Humadity: \(forecast.current.humidity)%")
                                    .font(.system(size: 25, weight: .medium))
                                    .multilineTextAlignment(.center)
                                Text("Pressure: \(forecast.current.pressure)pHa")
                                    .font(.system(size: 25, weight: .medium))
                                    .multilineTextAlignment(.center)
                                Text("Wind Speed: \(wind)mph")
                                    .font(.system(size: 25, weight: .medium))
                                    .multilineTextAlignment(.center)
                            } else {
                                Text("Temp: N/A")
                                    .font(.system(size: 25, weight: .medium))
                            }
                        }
                        Spacer()
                    }.padding()
                    Spacer()
                }
            }
        }
    }
}

struct WeatherNowView_Previews: PreviewProvider {
    static var previews: some View {
        WeatherNowView()
            .environmentObject(WeatherMapViewModel())
    }
}
