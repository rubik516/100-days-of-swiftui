import SwiftUI

struct ContentView: View {
    enum ViewMode {
        case Grid, List
    }
    
    struct MissionGrid: View {
        let columns = [
            GridItem(.adaptive(minimum: 150))
        ]
        
        let missions: [Mission]
        let missionCrew: (Mission) -> [String: Astronaut]
        
        var body: some View {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(missions) { mission in
                        NavigationLink {
                            MissionView(mission: mission, astronauts: missionCrew(mission))
                        } label: {
                            VStack {
                                Image(mission.image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
                                    .padding()
                                VStack {
                                    Text(mission.displayName)
                                        .font(.headline)
                                        .foregroundStyle(.white)
                                    Text(mission.formattedLaunchDate)
                                        .font(.caption)
                                        .foregroundStyle(.white.opacity(0.5))
                                }
                                .padding(.vertical)
                                .frame(maxWidth: .infinity)
                                .background(.lightBackground)
                            }
                            .clipShape(.rect(cornerRadius: 10))
                            .overlay {
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(.lightBackground)
                            }
                        }
                    }
                }
                .padding([.horizontal, .bottom])
            }
        }
    }
    
    struct MissionList: View {
        let missions: [Mission]
        let missionCrew: (Mission) -> [String: Astronaut]
        
        var body: some View {
            List {
                ForEach(missions) { mission in
                    NavigationLink {
                        MissionView(mission: mission, astronauts: missionCrew(mission))
                    } label: {
                        HStack {
                            Image(mission.image)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60, height: 60)
                                .padding()
                                .background(.darkBackground)
                                .clipShape(.rect(cornerRadius: 10))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(.white.opacity(0.5), lineWidth: 1)
                                }
                            VStack(alignment: .leading) {
                                Text(mission.displayName)
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                Text(mission.formattedLaunchDate)
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.5))
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .listRowBackground(Color.lightBackground)
            }
            .scrollContentBackground(.hidden)
        }
    }
    
    @State private var viewMode = ViewMode.Grid
    @State private var switchModeTitle = "Switch to List"
    @State private var switchModeIcon = "list.star"
    
    let astronauts: [String: Astronaut] = Bundle.main.decode("astronauts.json")
    let missions: [Mission] = Bundle.main.decode("missions.json")
    
    func missionCrew(for mission: Mission) -> [String: Astronaut] {
        var missionAstronauts = [String: Astronaut]()
        mission.crew.forEach { member in
            if let astronaut = astronauts[member.name] {
                missionAstronauts[member.name] = astronaut
            } else {
                fatalError("Missing crew member \(member.name)")
            }
        }
        return missionAstronauts
    }
    
    func switchViewMode() {
        if viewMode == ViewMode.Grid {
            viewMode = ViewMode.List
            switchModeIcon = "square.grid.2x2.fill"
            switchModeTitle = "Switch to Grid"
            return
        }
        viewMode = ViewMode.Grid
        switchModeIcon = "list.star"
        switchModeTitle = "Switch to List"
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if viewMode == ViewMode.Grid {
                    MissionGrid(missions: missions, missionCrew: missionCrew)
                } else {
                    MissionList(missions: missions, missionCrew: missionCrew)
                }
            }
            .navigationTitle("Moonshot")
            .background(.darkBackground)
            .preferredColorScheme(.dark)
            .toolbar {
                Button(switchModeTitle, systemImage: switchModeIcon) {
                    switchViewMode()
                }
            }
        }
        .accentColor(.white)
    }
}

#Preview {
    ContentView()
}
