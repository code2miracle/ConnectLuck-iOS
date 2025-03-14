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
    private let recommendedEvents = Event.dummyData()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) { // 섹션 간 간격 24pt
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
            .background(CLColor.SwiftUI.backgroundBase) // 배경색 적용
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
                            .foregroundColor(CLColor.SwiftUI.textPrimary)
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
        SearchBar(text: $searchText, placeholder: "푸드트럭 또는 행사 검색")
            .padding(.horizontal, 16) // 화면 가장자리 여백 16pt
            .padding(.top, 8)
    }
    
    private var welcomeSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let user = userState.currentUser {
                Text("안녕하세요, \(user.name)님")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(CLColor.SwiftUI.textPrimary)
                
                if userState.isEventManager {
                    Text("당신의 행사에 맞는 푸드트럭을 찾아보세요")
                        .font(.system(size: 16))
                        .foregroundColor(CLColor.SwiftUI.textSecondary)
                } else if userState.isFoodTruckManager {
                    Text("참여 가능한 행사를 확인해보세요")
                        .font(.system(size: 16))
                        .foregroundColor(CLColor.SwiftUI.textSecondary)
                } else {
                    Text("오늘은 어떤 맛있는 음식을 찾고 계신가요?")
                        .font(.system(size: 16))
                        .foregroundColor(CLColor.SwiftUI.textSecondary)
                }
            } else {
                Text("Connect Luck에 오신 것을 환영합니다")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(CLColor.SwiftUI.textPrimary)
                
                Text("로그인하고 더 많은 기능을 이용해보세요")
                    .font(.system(size: 16))
                    .foregroundColor(CLColor.SwiftUI.textSecondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
    
    private var activeFoodTrucksSection: some View {
        VStack(alignment: .leading, spacing: 12) { // 요소 간 간격 12pt
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
                    ForEach(recommendedEvents) { event in
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
                ForEach(recommendedEvents) { event in
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

// SearchBar, SectionHeader, ActiveFoodTruckCard, FoodTypeTag, StatusBadge, InfoRow 같은 컴포넌트는 변경 없음

struct EventCard: View {
    let event: Event
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 이미지
            ZStack(alignment: .topTrailing) {
                AsyncImage(url: URL(string: event.imageUrl)) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .fill(CLColor.SwiftUI.surface)
                            .aspectRatio(16/9, contentMode: .fill)
                            .frame(width: 280, height: 140)
                            .cornerRadius(8)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 280, height: 140)
                            .cornerRadius(8)
                            .clipped()
                    case .failure:
                        Rectangle()
                            .fill(CLColor.SwiftUI.surface)
                            .aspectRatio(16/9, contentMode: .fill)
                            .frame(width: 280, height: 140)
                            .cornerRadius(8)
                            .overlay(
                                Image(systemName: "photo")
                                    .foregroundColor(CLColor.SwiftUI.textSecondary)
                            )
                    @unknown default:
                        Rectangle()
                            .fill(CLColor.SwiftUI.surface)
                            .aspectRatio(16/9, contentMode: .fill)
                            .frame(width: 280, height: 140)
                            .cornerRadius(8)
                    }
                }
                
                // 이벤트 상태 배지
                StatusBadge(status: event.status)
                    .padding([.top, .trailing], 12)
            }
            
            // 정보
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.system(size: 20, weight: .semibold)) // Title3 스타일
                    .foregroundColor(CLColor.SwiftUI.textPrimary)
                    .lineLimit(1)
                
                InfoRow(icon: "mappin.and.ellipse", text: event.address)
                
                InfoRow(icon: "calendar", text: event.dateRange)
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 12)
        }
        .frame(width: 280)
        .background(CLColor.SwiftUI.backgroundBase)
        .cornerRadius(12) // 큰 카드 코너 반경 12pt
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
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
                        .fill(CLColor.SwiftUI.surface)
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
                        .fill(CLColor.SwiftUI.surface)
                        .frame(width: 60, height: 60)
                        .cornerRadius(8)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(CLColor.SwiftUI.textSecondary)
                        )
                @unknown default:
                    Rectangle()
                        .fill(CLColor.SwiftUI.surface)
                        .frame(width: 60, height: 60)
                        .cornerRadius(8)
                }
            }
            
            // 정보
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(CLColor.SwiftUI.textPrimary)
                
                HStack(spacing: 8) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 12))
                        .foregroundColor(CLColor.SwiftUI.textSecondary)
                    
                    Text(event.streetAddress)
                        .font(.system(size: 14))
                        .foregroundColor(CLColor.SwiftUI.textSecondary)
                        .lineLimit(1)
                    
                    // String+Extension 사용하여 날짜 포맷팅
                    if let formattedDate = event.startAt.toFormattedDate() {
                        Text(formattedDate)
                            .font(.system(size: 14))
                            .foregroundColor(CLColor.SwiftUI.textSecondary)
                    }
                }
            }
            
            Spacer()
            
            // 화살표 아이콘
            Image(systemName: "chevron.right")
                .foregroundColor(CLColor.SwiftUI.textSecondary)
        }
        .padding(16)
        .background(CLColor.SwiftUI.backgroundBase)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

struct NotificationsView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("알림이 없습니다")
                    .font(.system(size: 16))
                    .foregroundColor(CLColor.SwiftUI.textSecondary)
                    .padding()
            }
            .background(CLColor.SwiftUI.backgroundBase)
            .navigationTitle("알림")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
// MARK: - 보조 뷰 컴포넌트

struct SearchBar: View {
    @Binding var text: String
    var placeholder: String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(CLColor.SwiftUI.textSecondary)

            TextField(placeholder, text: $text)
                .font(.system(size: 17))
                .foregroundColor(CLColor.SwiftUI.textPrimary)

            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(CLColor.SwiftUI.textSecondary)
                }
            }
        }
        .padding(.horizontal, 12)
        .frame(height: 40)
        .background(CLColor.SwiftUI.surface)
        .cornerRadius(8) // 중간 카드 코너 반경 8pt
    }
}

struct SectionHeader: View {
    let title: String
    let actionText: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 22, weight: .bold)) // Title2 스타일
                .foregroundColor(CLColor.SwiftUI.textPrimary)
            
            Spacer()
            
            Button(action: {
                // 더보기 액션
            }) {
                Text(actionText)
                    .font(.system(size: 15)) // Subheadline 스타일
                    .foregroundColor(CLColor.SwiftUI.primaryColor)
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
                        .fill(CLColor.SwiftUI.surface)
                        .aspectRatio(16/9, contentMode: .fill)
                        .frame(width: 160, height: 100)
                        .cornerRadius(8)
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 160, height: 100)
                        .cornerRadius(8)
                        .clipped()
                case .failure:
                    Rectangle()
                        .fill(CLColor.SwiftUI.surface)
                        .aspectRatio(16/9, contentMode: .fill)
                        .frame(width: 160, height: 100)
                        .cornerRadius(8)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(CLColor.SwiftUI.textSecondary)
                        )
                @unknown default:
                    Rectangle()
                        .fill(CLColor.SwiftUI.surface)
                        .aspectRatio(16/9, contentMode: .fill)
                        .frame(width: 160, height: 100)
                        .cornerRadius(8)
                }
            }
            
            // 정보
            VStack(alignment: .leading, spacing: 4) {
                Text(truck.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(CLColor.SwiftUI.textPrimary)
                    .lineLimit(1)
                
                if let foodTypeEnum = truck.foodTypeEnum {
                    FoodTypeTag(type: foodTypeEnum.displayName)
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 12))
                        .foregroundColor(CLColor.SwiftUI.accentColor)
                    
                    Text(String(format: "%.1f", truck.avgRating))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(CLColor.SwiftUI.textPrimary)
                    
                    Text("(\(truck.reviewCount))")
                        .font(.system(size: 12))
                        .foregroundColor(CLColor.SwiftUI.textSecondary)
                }
            }
        }
        .frame(width: 160)
        .padding(.bottom, 8)
        .background(CLColor.SwiftUI.backgroundBase)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

struct FoodTypeTag: View {
    var type: String

    var body: some View {
        Text(type)
            .font(.system(size: 13)) // Footnote 스타일
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(CLColor.SwiftUI.primaryColor.opacity(0.1))
            .foregroundColor(CLColor.SwiftUI.primaryColor)
            .cornerRadius(4) // 작은 요소 코너 반경 4pt
    }
}

struct InfoRow: View {
    var icon: String
    var text: String
        
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(CLColor.SwiftUI.textSecondary)
            
            Text(text)
                .font(.system(size: 15)) // Subheadline 스타일
                .foregroundColor(CLColor.SwiftUI.textSecondary)
                .lineLimit(1)
        }
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
                        .fill(CLColor.SwiftUI.surface)
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
                        .fill(CLColor.SwiftUI.surface)
                        .frame(width: 60, height: 60)
                        .cornerRadius(8)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(CLColor.SwiftUI.textSecondary)
                        )
                @unknown default:
                    Rectangle()
                        .fill(CLColor.SwiftUI.surface)
                        .frame(width: 60, height: 60)
                        .cornerRadius(8)
                }
            }
            
            // 정보
            VStack(alignment: .leading, spacing: 4) {
                Text(truck.name)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(CLColor.SwiftUI.textPrimary)
                
                HStack(spacing: 8) {
                    if let foodTypeEnum = truck.foodTypeEnum {
                        Text(foodTypeEnum.displayName)
                            .font(.system(size: 14))
                            .foregroundColor(CLColor.SwiftUI.textSecondary)
                    }
                    
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 12))
                            .foregroundColor(CLColor.SwiftUI.accentColor)
                        
                        Text(String(format: "%.1f", truck.avgRating))
                            .font(.system(size: 14))
                            .foregroundColor(CLColor.SwiftUI.textPrimary)
                    }
                }
            }
            
            Spacer()
            
            // 화살표 아이콘
            Image(systemName: "chevron.right")
                .foregroundColor(CLColor.SwiftUI.textSecondary)
        }
        .padding(16) // 컴포넌트 내부 여백 16pt
        .background(CLColor.SwiftUI.backgroundBase)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    HomeView()
}
