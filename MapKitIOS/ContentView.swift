import SwiftUI
import MapKit

struct ContentView: View {
    var body: some View {
        MapView()
    }
}

struct MapView: UIViewRepresentable {
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: UIScreen.main.bounds)
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        
        // Установка региона на карте
        let initialLocation = CLLocation(latitude: 37.7749, longitude: -122.4194) // Начальное местоположение
        let regionRadius: CLLocationDistance = 1000 // Радиус отображаемой области карты
        zoomMapOn(mapView: mapView, location: initialLocation, radius: regionRadius)
        
        // Создание и добавление маркеров на карту
        let sourceLocation = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194) // Начальная точка
        let destinationLocation = CLLocationCoordinate2D(latitude: 37.3366, longitude: -121.8946) // Конечная точка
        let sourcePlacemark = MKPlacemark(coordinate: sourceLocation)
        let destinationPlacemark = MKPlacemark(coordinate: destinationLocation)
        mapView.addAnnotation(sourcePlacemark)
        mapView.addAnnotation(destinationPlacemark)
        
        // Построение маршрута между точками
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        let directionRequest = MKDirections.Request()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = .automobile // Тип транспорта (автомобиль, пешком и т.д.)
        
        let directions = MKDirections(request: directionRequest)
        directions.calculate { response, error in
            guard let response = response else {
                if let error = error {
                    print("Ошибка при построении маршрута: \(error.localizedDescription)")
                }
                return
            }
            
            let route = response.routes[0] // Получение первого маршрута из ответа
            mapView.addOverlay(route.polyline, level: .aboveRoads) // Отображение маршрута на карте
        }
        
        return mapView
    }
    
    func updateUIView(_ view: MKMapView, context: Context) {
        // Можете добавить обновление карты, если необходимо.
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    // Функция для установки отображаемой области карты
    func zoomMapOn(mapView: MKMapView, location: CLLocation, radius: CLLocationDistance) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: radius, longitudinalMeters: radius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    // Координатор для обработки делегатов MKMapView
    class Coordinator: NSObject, MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = UIColor.blue
            renderer.lineWidth = 3.0
            return renderer
        }
    }
}
