//
//  HourWeatherView.swift
//  CWK2Template
//
//  Created by girish lukka on 02/11/2023.
//

    import SwiftUI

    struct HourWeatherView: View {
        var current: Current
        @EnvironmentObject var weatherMapViewModel: WeatherMapViewModel
        var body: some View {
            let formattedDate = DateFormatterUtils.formattedDateWithDay(from: TimeInterval(current.dt))
                VStack(alignment: .center, spacing: 5) {
                    Text(formattedDate)
                    .font(.body)
                    .offset(y: 17)
                    .padding(.horizontal)   
                    .background(Color.teal)
                    .foregroundColor(.black)
                
                if let weather = weatherMapViewModel.weatherDataModel{
                    let viewIdentifier = "\(weather.id)-\(current.id)"

                    
                    AsyncImage (url:URL( string: "https://openweathermap.org/img/wn/\(current.weather[0].icon)@2x.png"))
                        .offset(y: 15)
                        .scaleEffect(0.5)
                        .frame(width:70, height: 70,alignment: .center)
                        .scaledToFit()
                        .clipped()
                        .id(viewIdentifier)
                    Text("\(Int(current.temp))ºC")
                        .frame(alignment: .center)
                        .id(viewIdentifier)

                    Text(" \(current.weather[0].weatherDescription.rawValue)")
                        .offset(y: -5)
                        .multilineTextAlignment(.center)
                        .frame(width: 125)
                        .font(.body)
                        .lineLimit(nil)
                        .padding(.horizontal)
                        .background(Color.teal)
                        .foregroundColor(.black)
                        .ignoresSafeArea(.all)
                        .id(viewIdentifier)

                }
            }
        }
    }




