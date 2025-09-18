struct BadgeView: View {
    let count: Int
    
    var body: some View {
        Text("\(count)")
            .font(.system(size: 12))
            .foregroundColor(.white)
            .padding(4)
            .background(Color.red)
            .clipShape(Circle())
            .offset(x: 10, y: -10)
    }
}