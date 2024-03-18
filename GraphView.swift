//
//  GraphView.swift
//  test2
//
//  Created by Hayden Hubert on 1/12/24.
//
import SwiftUI
import Charts

struct GraphDataPoint {
    var frequency: Double
    var interval: Double
}

struct LineChart: View {
    var data: [GraphDataPoint]
    let xAxisLabel: String
    let yAxisLabel: String

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Path { path in
                    for (index, point) in data.enumerated() {
                        let x = CGFloat(point.frequency / data.map { $0.frequency }.max()!) * geometry.size.width
                        let y = geometry.size.height - CGFloat(point.interval / data.map { $0.interval }.max()!) * geometry.size.height
                        let point = CGPoint(x: x, y: y)

                        if index == 0 {
                            path.move(to: point)
                        } else {
                            path.addLine(to: point)
                        }
                    }
                }
                .stroke(Color.blue, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))

                ForEach(data.indices, id: \.self) { index in
                    let point = data[index]
                    let x = CGFloat(point.frequency / data.map { $0.frequency }.max()!) * geometry.size.width
                    let y = geometry.size.height - CGFloat(point.interval / data.map { $0.interval }.max()!) * geometry.size.height
                    let center = CGPoint(x: x, y: y)

                    Circle()
                        .fill(Color.blue)
                        .frame(width: 6, height: 6)
                        .position(center)
                }

                Rectangle()
                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)

                Text(yAxisLabel)
                    .rotationEffect(.degrees(-90))
                    .font(.caption)
                    .frame(width: geometry.size.height, height: 20, alignment: .center)
                    .offset(x: -geometry.size.height / 2, y: 0)

                Text(xAxisLabel)
                    .font(.caption)
                    .frame(width: geometry.size.width, height: 20, alignment: .center)
                    .offset(x: 0, y: geometry.size.height / 2)

                ForEach(0..<6) { index in
                    Text("\(index * 10)")
                        .font(.caption)
                        .frame(width: 20, height: 10, alignment: .center)
                        .offset(x: CGFloat(index) * geometry.size.width / 5 - 5, y: geometry.size.height / 2 + 20)
                }
            }
        }
    }
}

struct GraphView: View {
    @State private var selectedAxis = "X" // Initial axis selection

    // Sample motion data
    let motionData: [MotionData] = [
        MotionData(timestamp: Date(), accelerationX: 0.5, accelerationY: 0.6, accelerationZ: 0.7),
        MotionData(timestamp: Date().addingTimeInterval(1), accelerationX: 0.6, accelerationY: 0.7, accelerationZ: 0.8),
        MotionData(timestamp: Date().addingTimeInterval(2), accelerationX: 0.7, accelerationY: 0.8, accelerationZ: 0.9),
        MotionData(timestamp: Date().addingTimeInterval(3), accelerationX: 0.8, accelerationY: 0.9, accelerationZ: 1.0)
        // Add more motion data points as needed
    ]

    let axes = ["X", "Y", "Z"] // Axis options for selection

    var body: some View {
        VStack {
            Text("Motion Data Graph")
                .font(.largeTitle)
                .foregroundColor(.blue)

            Picker("Select Axis", selection: $selectedAxis) {
                ForEach(axes, id: \.self) { axis in
                    Text(axis)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            LineChart(data: motionData.dataPointsForAxis(axis: selectedAxis),
                      xAxisLabel: "Acceleration",
                      yAxisLabel: "Time")
                .padding()
                .frame(height: 300)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        GraphView()
    }
}
