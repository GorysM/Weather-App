import SwiftUI
import CoreLocation
import MapKit

struct TouristPlacesMapView: View {
    @EnvironmentObject var weatherMapViewModel: WeatherMapViewModel
    @State var locations: [Location] = []
    @State var mapRegion = MKCoordinateRegion()
    @State private var selectedLocation: Location?
    @State private var isShowingDetail = false
    
    var body: some View {
        NavigationView {
                VStack{
                    if weatherMapViewModel.coordinates == nil {
                        VStack(spacing: 10) {
                            Map(
                                coordinateRegion: weatherMapViewModel.coordinates == nil ? $mapRegion : .constant(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.5081, longitude: -0.0759), latitudinalMeters: 3000, longitudinalMeters: 3000)),
                                annotationItems: locations)
                            { location in
                                MapAnnotation(coordinate: location.coordinates) {
                                    Image(systemName: "mappin.circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(.red)
                                }
                            }
                            .edgesIgnoringSafeArea(.top)
                            .frame(height: 300)
                            VStack {
                                Text("Tourist Attractions on \(weatherMapViewModel.city)")
                                    .multilineTextAlignment(.leading)
                            }
                            .ignoresSafeArea(.all)
                            
                        }
                        
                    }else{
                        VStack(spacing: 10) {
                            
                            Map(
                                coordinateRegion: $mapRegion,
                                annotationItems: locations
                            ) { location in
                                MapAnnotation(coordinate: location.coordinates) {
                                    Image(systemName: "mappin.circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(.red)
                                }
                            }
                            .edgesIgnoringSafeArea(.all)
                            .frame(height: 300)
                            
                            
                        }
                        
                    }
                    ScrollView{
                        List {
                            ForEach(filteredLocations()) { location in
                                LocationRowView(location: location)
                                    .onTapGesture {
                                        selectedLocation = location
                                        isShowingDetail.toggle()
                                    }
                            }
                        }
                        .listStyle(GroupedListStyle())
                        .frame(height: 700)
                        .ignoresSafeArea()
                        
                    }
                }
                
                .onAppear {
                    self.loadTouristPlaces()
                    Task {
                        do {
                            try await setAnnotations()
                        } catch {
                            print("Error setting annotations: \(error)")
                        }
                    }
                }
                .sheet(isPresented: $isShowingDetail) {
                    if let selectedLocation = selectedLocation {
                        LocationDetailView(location: selectedLocation, isShowingDetail: $isShowingDetail)
                    }
                }
        }
    }
    func loadTouristPlaces() {
        if let allLocations = weatherMapViewModel.loadLocationsFromJSONFile(cityName: weatherMapViewModel.city) {
            self.locations = allLocations
        }
    }
    
    func setAnnotations() async throws {
          guard let coordinates = weatherMapViewModel.coordinates else {
              // If coordinates are nil, set a default region
              self.mapRegion = MKCoordinateRegion(
                  center: CLLocationCoordinate2D(latitude: 51.5216871, longitude: -0.1391574),
                  latitudinalMeters: 3000,
                  longitudinalMeters: 3000
              )
              return
          }

          let request = MKLocalSearch.Request()
          request.naturalLanguageQuery = "places"
          request.region = MKCoordinateRegion(
              center: CLLocationCoordinate2D(latitude: coordinates.latitude, longitude: coordinates.longitude),
              latitudinalMeters: 5000,
              longitudinalMeters: 5000
          )

          let search = MKLocalSearch(request: request)
          let results = try await search.start()
        
        // to set the map region
        self.mapRegion = MKCoordinateRegion(
            center: results.boundingRegion.center,
            span: MKCoordinateSpan(
                latitudeDelta: results.boundingRegion.span.latitudeDelta * 1.2,
                longitudeDelta: results.boundingRegion.span.longitudeDelta * 1.2
            )
        )
    }
    
    func filteredLocations() -> [Location] {
        return locations.filter { $0.cityName.lowercased() == weatherMapViewModel.city.lowercased() }
    }
}

struct TouristPlacesMapView_Previews: PreviewProvider {
    static var previews: some View {
        TouristPlacesMapView()
            .environmentObject(WeatherMapViewModel())
    }
}

struct LocationRowView: View {
    let location: Location
    
    var body: some View {
        HStack {
            Image(location.imageNames[0])
                .resizable()
                .scaleEffect(0.7)
                .frame(width: 150, height: 150)
                .font(.subheadline)
            Text("\(location.name)")
                .font(.subheadline)
        }
    }
}

struct LocationDetailView: View {
    let location: Location
    @Binding var isShowingDetail: Bool
    
    var body: some View {
        // view to display detailed information
        VStack {
            Text(location.name)
                .font(.title)
            Image(location.imageNames[0])
                .resizable()
                .scaledToFit()
                .frame(height: 200)
                .cornerRadius(/*@START_MENU_TOKEN@*/3.0/*@END_MENU_TOKEN@*/)
            Text(location.description)
                .padding()
            Button("Dismiss") {
                isShowingDetail.toggle()
            }
        }
    }
}
