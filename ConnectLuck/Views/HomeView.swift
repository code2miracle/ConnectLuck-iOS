//
//  HomeView.swift
//  ConnectLuck
//
//  Created by 이종민 on 3/14/25.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var userState: UserState
    @State private var searchText = ""
    @State private var showingNotifications = false
    
    // 최근 푸드트럭 더미 데이터
    private let recentFoodTrucks = FoodTruck.dummyData().prefix(5)
    
    // 추천 행사 더미 데이터
    private let recommendedEvents = [
        Event(id: 1, name: "부산 푸드 페스티벌", description: "부산 최대 규모의 푸드 페스티벌", location: "부산 해운대", startDate: "2025-04-15", endDate: "2025-04-20", imageUrl: "https://picsum.photos/id/292/800/600", organizerName: "부산시청"),
        Event(id: 2, name: "서울 야시장", description: "서울 밤을 밝히는 맛있는 야시장", location: "서울 여의도", startDate: "2025-05-01", endDate: "2025-05-03", imageUrl: "https://picsum.photos/id/431/800/600", organizerName: "서울시청"),
        Event(id: 3, name: "대학 축제", description: "대학 봄 축제", location: "서울대학교", startDate: "2025-05-10", endDate: "2025-05-12", imageUrl: "https://picsum.photos/id/1080/800/600", organizerName: "서울대학교 총학생회")
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // 검색 바
                    searchBar
                    
                    // 사용자 맞춤 섹션
                    welcomeSection
                    
                    // 현재 활동 중인 푸드트럭
                    activeFoodTrucksSection
                    
                    // 추천 행사
                    recommendedEventsSection
                    
                    // 맞춤 푸드트럭 추천 (역할에 따라 다른 내용 표시)
                    if userState.isEventManager {
                        recommendedFoodTruckForEventSection
                    } else if userState.isFoodTruckManager {
                        recommendedEventsForFoodTruckSection
                    } else {
                        popularFoodTruckSection
                    }
                }
                .padding(.bottom, 16)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Image("ConnectLuckLogo") // 로고 이미지 필요
                        .resizable()
                        .scaledToFit()
                        .frame(height: 24)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingNotifications.toggle()
                    } label: {
                        Image(systemName: "bell")
                            .foregroundColor(Color(hex: "#212121"))
                    }
                }
            }
            .sheet(isPresented: $showingNotifications) {
                NotificationsView()
            }
        }
    }
    
    // MARK: - 컴포넌트
    
    private var searchBar: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Color(hex: "#757575"))
                
                TextField("푸드트럭 또는 행사 검색", text: $searchText)
                    .font(.system(size: 16))
                
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(Color(hex: "#757575"))
                    }
                }
            }
            .padding(12)
            .background(Color(hex: "#F5F5F5"))
            .cornerRadius(10)
        }
        .padding(.horizontal, 16)
    }
    
    private var welcomeSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let user = userState.currentUser {
                Text("안녕하세요, \(user.name)님")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(Color(hex: "#212121"))
                
                if userState.isEventManager {
                    Text("당신의 행사에 맞는 푸드트럭을 찾아보세요")
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: "#757575"))
                } else if userState.isFoodTruckManager {
                    Text("참여 가능한 행사를 확인해보세요")
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: "#757575"))
                } else {
                    Text("오늘은 어떤 맛있는 음식을 찾고 계신가요?")
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: "#757575"))
                }
            } else {
                Text("Connect Luck에 오신 것을 환영합니다")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(Color(hex: "#212121"))
                
                Text("로그인하고 더 많은 기능을 이용해보세요")
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: "#757575"))
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
    
    private var activeFoodTrucksSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "지금 영업 중인 푸드트럭", actionText: "더보기")
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(recentFoodTrucks, id: \.id) { truck in
                        ActiveFoodTruckCard(truck: truck)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
    
    private var recommendedEventsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "다가오는 행사", actionText: "전체보기")
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(recommendedEvents, id: \.id) { event in
                        EventCard(event: event)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
    
    private var recommendedFoodTruckForEventSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "당신의 행사에 추천하는 푸드트럭", actionText: "더보기")
            
            VStack(spacing: 12) {
                ForEach(recentFoodTrucks, id: \.id) { truck in
                    RecommendedFoodTruckRow(truck: truck)
                }
            }
            .padding(.horizontal, 16)
        }
    }
    
    private var recommendedEventsForFoodTruckSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "참여 가능한 행사", actionText: "더보기")
            
            VStack(spacing: 12) {
                ForEach(recommendedEvents, id: \.id) { event in
                    RecommendedEventRow(event: event)
                }
            }
            .padding(.horizontal, 16)
        }
    }
    
    private var popularFoodTruckSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "인기 푸드트럭", actionText: "더보기")
            
            VStack(spacing: 12) {
                ForEach(recentFoodTrucks, id: \.id) { truck in
                    RecommendedFoodTruckRow(truck: truck)
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - 보조 뷰 컴포넌트

struct SectionHeader: View {
    let title: String
    let actionText: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(Color(hex: "#212121"))
            
            Spacer()
            
            Button(action: {
                // 더보기 액션
            }) {
                Text(actionText)
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "#0066CC"))
            }
        }
        .padding(.horizontal, 16)
    }
}

struct ActiveFoodTruckCard: View {
    let truck: FoodTruck
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 이미지
            AsyncImage(url: URL(string: truck.imageUrl)) { phase in
                switch phase {
                case .empty:
                    Rectangle()
                        .fill(Color(hex: "#E0E0E0"))
                        .aspectRatio(16/9, contentMode: .fill)
                        .frame(width: 160, height: 100)
                        .cornerRadius(12)
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 160, height: 100)
                        .cornerRadius(12)
                        .clipped()
                case .failure:
                    Rectangle()
                        .fill(Color(hex: "#E0E0E0"))
                        .aspectRatio(16/9, contentMode: .fill)
                        .frame(width: 160, height: 100)
                        .cornerRadius(12)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(Color(hex: "#9E9E9E"))
                        )
                @unknown default:
                    Rectangle()
                        .fill(Color(hex: "#E0E0E0"))
                        .aspectRatio(16/9, contentMode: .fill)
                        .frame(width: 160, height: 100)
                        .cornerRadius(12)
                }
            }
            
            // 정보
            VStack(alignment: .leading, spacing: 4) {
                Text(truck.name)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(hex: "#212121"))
                    .lineLimit(1)
                
                if let foodTypeEnum = truck.foodTypeEnum {
                    Text(foodTypeEnum.displayName)
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "#757575"))
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "#F7C948")) // 별점 컬러
                    
                    Text(String(format: "%.1f", truck.avgRating))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(hex: "#212121"))
                    
                    Text("(\(truck.reviewCount))")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "#9E9E9E"))
                }
            }
        }
        .frame(width: 160)
    }
}

struct EventCard: View {
    let event: Event
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 이미지
            AsyncImage(url: URL(string: event.imageUrl)) { phase in
                switch phase {
                case .empty:
                    Rectangle()
                        .fill(Color(hex: "#E0E0E0"))
                        .aspectRatio(16/9, contentMode: .fill)
                        .frame(width: 280, height: 140)
                        .cornerRadius(12)
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 280, height: 140)
                        .cornerRadius(12)
                        .clipped()
                case .failure:
                    Rectangle()
                        .fill(Color(hex: "#E0E0E0"))
                        .aspectRatio(16/9, contentMode: .fill)
                        .frame(width: 280, height: 140)
                        .cornerRadius(12)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(Color(hex: "#9E9E9E"))
                        )
                @unknown default:
                    Rectangle()
                        .fill(Color(hex: "#E0E0E0"))
                        .aspectRatio(16/9, contentMode: .fill)
                        .frame(width: 280, height: 140)
                        .cornerRadius(12)
                }
            }
            
            // 정보
            VStack(alignment: .leading, spacing: 4) {
                Text(event.name)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Color(hex: "#212121"))
                    .lineLimit(1)
                
                Text(event.location)
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "#757575"))
                
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "#757575"))
                    
                    Text("\(formatDate(event.startDate)) - \(formatDate(event.endDate))")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "#757575"))
                }
            }
            .padding(.horizontal, 4)
        }
        .frame(width: 280)
    }
    
    // 날짜 포맷 함수
    private func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let date = formatter.date(from: dateString) {
            formatter.dateFormat = "MM/dd"
            return formatter.string(from: date)
        }
        return dateString
    }
}

struct RecommendedFoodTruckRow: View {
    let truck: FoodTruck
    
    var body: some View {
        HStack(spacing: 12) {
            // 이미지
            AsyncImage(url: URL(string: truck.imageUrl)) { phase in
                switch phase {
                case .empty:
                    Rectangle()
                        .fill(Color(hex: "#E0E0E0"))
                        .frame(width: 60, height: 60)
                        .cornerRadius(8)
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 60, height: 60)
                        .cornerRadius(8)
                        .clipped()
                case .failure:
                    Rectangle()
                        .fill(Color(hex: "#E0E0E0"))
                        .frame(width: 60, height: 60)
                        .cornerRadius(8)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(Color(hex: "#9E9E9E"))
                        )
                @unknown default:
                    Rectangle()
                        .fill(Color(hex: "#E0E0E0"))
                        .frame(width: 60, height: 60)
                        .cornerRadius(8)
                }
            }
            
            // 정보
            VStack(alignment: .leading, spacing: 4) {
                Text(truck.name)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(hex: "#212121"))
                
                HStack(spacing: 8) {
                    if let foodTypeEnum = truck.foodTypeEnum {
                        Text(foodTypeEnum.displayName)
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "#757575"))
                    }
                    
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "#F7C948"))
                        
                        Text(String(format: "%.1f", truck.avgRating))
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "#212121"))
                    }
                }
            }
            
            Spacer()
            
            // 화살표 아이콘
            Image(systemName: "chevron.right")
                .foregroundColor(Color(hex: "#9E9E9E"))
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: "#E0E0E0"), lineWidth: 1)
        )
    }
}

struct RecommendedEventRow: View {
    let event: Event
    
    var body: some View {
        HStack(spacing: 12) {
            // 이미지
            AsyncImage(url: URL(string: event.imageUrl)) { phase in
                switch phase {
                case .empty:
                    Rectangle()
                        .fill(Color(hex: "#E0E0E0"))
                        .frame(width: 60, height: 60)
                        .cornerRadius(8)
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 60, height: 60)
                        .cornerRadius(8)
                        .clipped()
                case .failure:
                    Rectangle()
                        .fill(Color(hex: "#E0E0E0"))
                        .frame(width: 60, height: 60)
                        .cornerRadius(8)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(Color(hex: "#9E9E9E"))
                        )
                @unknown default:
                    Rectangle()
                        .fill(Color(hex: "#E0E0E0"))
                        .frame(width: 60, height: 60)
                        .cornerRadius(8)
                }
            }
            
            // 정보
            VStack(alignment: .leading, spacing: 4) {
                Text(event.name)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(hex: "#212121"))
                
                HStack(spacing: 8) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "#757575"))
                    
                    Text(event.location)
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "#757575"))
                        .lineLimit(1)
                    
                    Text(formatDate(event.startDate))
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "#757575"))
                }
            }
            
            Spacer()
            
            // 화살표 아이콘
            Image(systemName: "chevron.right")
                .foregroundColor(Color(hex: "#9E9E9E"))
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: "#E0E0E0"), lineWidth: 1)
        )
    }
    
    // 날짜 포맷 함수
    private func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let date = formatter.date(from: dateString) {
            formatter.dateFormat = "MM/dd"
            return formatter.string(from: date)
        }
        return dateString
    }
}

struct NotificationsView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("알림이 없습니다")
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: "#757575"))
                    .padding()
            }
            .navigationTitle("알림")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// 이벤트 모델
struct Event: Identifiable {
    let id: Int
    let name: String
    let description: String
    let location: String
    let startDate: String
    let endDate: String
    let imageUrl: String
    let organizerName: String
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(UserState())
    }
}

#Preview {
    HomeView()
}
