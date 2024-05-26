import SwiftUI

struct CrewInfo: View {
    let crew: [MissionView.CrewMember]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Crew")
                .font(.title.bold())
                .padding(.bottom, 5)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(crew, id: \.astronaut.id) { member in
                        NavigationLink {
                            AstronautView(astronaut: member.astronaut)
                        } label: {
                            HStack {
                                Image(member.astronaut.id)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 120, height: 120)
                                    .clipShape(.circle)
                                    .overlay(
                                        Group {
                                            let memberRole = member.role.trimmingCharacters(in: .whitespacesAndNewlines)
                                            let isCommander = memberRole == "Commander" || memberRole == "Command Pilot"
                                            
                                            Circle()
                                                .strokeBorder(.white, lineWidth: isCommander ? 2 : 1)
                                        }
                                    )
                                    .padding(.trailing, 5)
                                
                                VStack(alignment: .leading) {
                                    Text(member.astronaut.name)
                                        .foregroundStyle(.white)
                                        .font(.headline)
                                    Text(member.role)
                                        .foregroundStyle(.white.opacity(0.5))
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }
        }
    }
}
struct MissionView: View {
    struct CrewMember {
        let role: String
        let astronaut: Astronaut
    }
    
    let mission: Mission
    let crew: [CrewMember]
    
    init(mission: Mission, astronauts: [String: Astronaut]) {
        self.mission = mission
        
        self.crew = mission.crew.map { member in
            if let astronaut = astronauts[member.name] {
                return CrewMember(role: member.role, astronaut: astronaut)
            }
            fatalError("Missing crew member \(member.name)")
        }
    }
    
    let divider: some View = Rectangle()
        .frame(height: 2)
        .foregroundStyle(.lightBackground)
        .padding(.vertical)
    
    var body: some View {
        ScrollView {
            VStack {
                Image(mission.image)
                    .resizable()
                    .scaledToFit()
                    .containerRelativeFrame(.horizontal) { width, axis in
                        width * 0.6
                    }
                
                divider
                
                VStack(alignment: .leading) {
                    Text("Mission Highlights")
                        .font(.title.bold())
                        .padding(.bottom, 5)
                    HStack {
                        Text("Launch Date:")
                            .font(.headline)
                        Text(mission.formattedLaunchDate)
                    }
                    .padding(.bottom, 5)
                    Text(mission.description)
                    divider
                }
                .padding(.horizontal)
                
                CrewInfo(crew: crew)
            }
            .padding(.vertical)
        }
        .navigationTitle(mission.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .background(.darkBackground)
    }
}

#Preview {
    let missions: [Mission] = Bundle.main.decode("missions.json")
    let astronauts: [String: Astronaut] = Bundle.main.decode("astronauts.json")
    return MissionView(mission: missions[0], astronauts: astronauts)
        .preferredColorScheme(.dark)
}
