struct PulsarView: View {
    @ObservedObject var model: PulsarModel
    
    var body: some View {
        ZStack {
            // Stars background
            ForEach(0..<200) { _ in
                Circle()
                    .fill(Color.white.opacity(Double.random(in: 0.2...0.6)))
                    .frame(width: CGFloat.random(in: 1...2), height: CGFloat.random(in: 1...2))
                    .position(x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                              y: CGFloat.random(in: 0...UIScreen.main.bounds.height))
            }
            
            // Particles (photons)
            ForEach(model.particles) { p in
                Circle()
                    .fill(p.color.opacity(p.opacity))
                    .frame(width: 6, height: 6)
                    .position(x: UIScreen.main.bounds.width/2 + CGFloat(cos(p.angle) * p.radius),
                              y: UIScreen.main.bounds.height/2 + CGFloat(sin(p.angle) * p.radius))
                    .blur(radius: 2)
            }
            
            // Rotating pulsar rings
            ZStack {
                ForEach(0..<3) { i in
                    Circle()
                        .stroke(
                            AngularGradient(
                                gradient: Gradient(colors: [model.pulsarColor().opacity(0.6), .clear]),
                                center: .center
                            ),
                            lineWidth: CGFloat(8 - 2*i)
                        )
                        .frame(width: 120 + CGFloat(i*20), height: 120 + CGFloat(i*20))
                        .rotationEffect(.degrees(model.rotation*10))
                        .blur(radius: 1.5)
                }
                
                // Glowing core
                Circle()
                    .fill(model.pulsarColor())
                    .frame(width: 40, height: 40)
                    .shadow(color: model.pulsarColor(), radius: 40)
                    .scaleEffect(1 + CGFloat(sin(model.rotation*5))*0.05)
                
                // Magnetic poles
                ForEach(0..<2) { i in
                    let angle = Double(i) * Double.pi + model.rotation*0.5
                    Circle()
                        .fill(Color.white)
                        .frame(width: 10, height: 10)
                        .position(x: UIScreen.main.bounds.width/2 + CGFloat(cos(angle)*50),
                                  y: UIScreen.main.bounds.height/2 + CGFloat(sin(angle)*50))
                        .shadow(color: .white, radius: 15)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
