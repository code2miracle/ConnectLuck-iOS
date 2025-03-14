//
//  FoodTruckDetailView.swift
//  ConnectLuck
//
//  Created by 이종민 on 3/14/25.
//

import SwiftUI

struct FoodTruckDetailView: View {
    let foodTruckId: Int
    @State private var detailViewModel = FoodTruckDetailViewModel()
    @State private var selectedTab = 0
    @State private var showReviewForm = false
    @State var userState: UserState
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // 이미지
                headerImage
                
                // 푸드트럭 정보
                VStack(alignment: .leading, spacing: 16) {
                    // 기본 정보
                    basicInfo
                    
                    Divider()
                        .background(CLColor.SwiftUI.divider)
                    
                    // 탭 선택
                    tabSelection
                    
                    // 탭 컨텐츠
                    tabContent
                }
                .padding(16)
            }
        }
        .background(CLColor.SwiftUI.backgroundBase)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showReviewForm = true
                } label: {
                    Label("리뷰 작성", systemImage: "square.and.pencil")
                        .font(.system(size: 14))
                        .foregroundColor(CLColor.SwiftUI.primaryColor)
                }
            }
        }
        .overlay {
            if detailViewModel.isLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .frame(width: 100, height: 100)
                    .background(Color.white.opacity(0.7))
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
            }
        }
        .task {
            await detailViewModel.fetchFoodTruckDetail(id: foodTruckId)
        }
        .alert(isPresented: $detailViewModel.showError) {
            Alert(
                title: Text("데이터 로드 실패"),
                message: Text(detailViewModel.errorMessage ?? "오류가 발생했습니다."),
                dismissButton: .default(Text("확인"))
            )
        }
        .sheet(isPresented: $showReviewForm) {
            // 리뷰 작성 폼 - 추후 구현
            VStack {
                Text("리뷰 작성 폼")
                    .font(.title)
                    .padding()
                
                Text("이 기능은 2단계 개발에서 구현 예정입니다.")
                    .foregroundColor(.secondary)
                    .padding()
                
                Button("닫기") {
                    showReviewForm = false
                }
                .padding()
            }
        }
    }
    
    // 헤더 이미지
    private var headerImage: some View {
        ZStack(alignment: .bottomLeading) {
            if let foodTruck = detailViewModel.foodTruckDetail {
                AsyncImage(url: URL(string: foodTruck.imageUrl)) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .fill(CLColor.SwiftUI.surface)
                            .aspectRatio(16/9, contentMode: .fill)
                            .frame(height: 220)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 220)
                            .clipped()
                    case .failure:
                        Rectangle()
                            .fill(CLColor.SwiftUI.surface)
                            .aspectRatio(16/9, contentMode: .fill)
                            .frame(height: 220)
                            .overlay {
                                Image(systemName: "photo")
                                    .font(.largeTitle)
                                    .foregroundColor(CLColor.SwiftUI.textSecondary)
                            }
                    @unknown default:
                        Rectangle()
                            .fill(CLColor.SwiftUI.surface)
                            .aspectRatio(16/9, contentMode: .fill)
                            .frame(height: 220)
                    }
                }
                
                // 푸드 타입 배지
                FoodTypeTag(type: foodTruck.foodType.displayName)
                    .padding(16)
            } else {
                Rectangle()
                    .fill(CLColor.SwiftUI.surface)
                    .aspectRatio(16/9, contentMode: .fill)
                    .frame(height: 220)
                    .overlay {
                        ProgressView()
                    }
            }
        }
    }
    
    // 기본 정보 섹션
    private var basicInfo: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let foodTruck = detailViewModel.foodTruckDetail {
                // 이름 및 평점
                HStack {
                    Text(foodTruck.name)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(CLColor.SwiftUI.textPrimary)
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(CLColor.SwiftUI.accentColor)
                            .font(.system(size: 16))
                        
                        Text(String(format: "%.1f", foodTruck.avgRating))
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(CLColor.SwiftUI.textPrimary)
                        
                        Text("(\(foodTruck.reviews.count))")
                            .font(.system(size: 14))
                            .foregroundColor(CLColor.SwiftUI.textSecondary)
                    }
                }
                
                // 운영자 정보
                HStack(spacing: 6) {
                    Text("운영자:")
                        .font(.system(size: 15))
                        .foregroundColor(CLColor.SwiftUI.textSecondary)
                    
                    Text(foodTruck.managerName)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(CLColor.SwiftUI.textPrimary)
                }
                
                // 설명
                Text(foodTruck.description)
                    .font(.system(size: 16))
                    .foregroundColor(CLColor.SwiftUI.textPrimary)
                    .padding(.top, 4)
                
                // 운영 관련 정보 - 현재는 더미 데이터
                HStack {
                    // 현재 영업 중이라고 가정
                    StatusBadge(status: .recruiting, text: "현재 영업 중")
                    
                    Spacer()
                    
                    // 위치 보기 버튼 - 3단계에서 구현 예정
                    Button {
                        // 지도 기능은 3단계에서 구현
                    } label: {
                        Label("위치 보기", systemImage: "map")
                            .font(.system(size: 14))
                            .foregroundColor(CLColor.SwiftUI.primaryColor)
                    }
                }
                .padding(.top, 8)
                
                // 푸드트럭 관리자인 경우 추가 버튼 표시
                if userState.isFoodTruckManager && userState.currentUser?.name == foodTruck.managerName {
                    HStack {
                        Spacer()
                        
                        Button {
                            // 영업 시작 기능은 3단계에서 구현
                        } label: {
                            Text("영업 시작")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(CLColor.SwiftUI.primaryColor)
                                .cornerRadius(8)
                        }
                    }
                    .padding(.top, 12)
                }
            } else {
                // 로딩 중인 경우의 스켈레톤 UI
                Rectangle()
                    .fill(CLColor.SwiftUI.surface)
                    .frame(height: 28)
                    .cornerRadius(4)
                
                Rectangle()
                    .fill(CLColor.SwiftUI.surface)
                    .frame(height: 20)
                    .cornerRadius(4)
                
                Rectangle()
                    .fill(CLColor.SwiftUI.surface)
                    .frame(height: 60)
                    .cornerRadius(4)
            }
        }
    }
    
    // 탭 선택 섹션
    private var tabSelection: some View {
        HStack(spacing: 0) {
            ForEach(0..<2) { index in
                Button {
                    withAnimation {
                        selectedTab = index
                    }
                } label: {
                    VStack(spacing: 8) {
                        Text(index == 0 ? "메뉴" : "리뷰")
                            .font(.system(size: 16, weight: selectedTab == index ? .semibold : .regular))
                            .foregroundColor(selectedTab == index ? CLColor.SwiftUI.primaryColor : CLColor.SwiftUI.textSecondary)
                            .frame(maxWidth: .infinity)
                        
                        Rectangle()
                            .fill(selectedTab == index ? CLColor.SwiftUI.primaryColor : Color.clear)
                            .frame(height: 2)
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    // 탭 컨텐츠
    private var tabContent: some View {
        VStack {
            if selectedTab == 0 {
                // 메뉴 탭
                menuContent
            } else {
                // 리뷰 탭
                reviewContent
            }
        }
    }
    
    // 메뉴 컨텐츠
    private var menuContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let foodTruck = detailViewModel.foodTruckDetail {
                if foodTruck.menus.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "fork.knife")
                            .font(.system(size: 40))
                            .foregroundColor(CLColor.SwiftUI.textSecondary)
                            .padding(.top, 40)
                        
                        Text("등록된 메뉴가 없습니다")
                            .font(.system(size: 16))
                            .foregroundColor(CLColor.SwiftUI.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                } else {
                    ForEach(foodTruck.menus) { menu in
                        MenuItemRow(menuItem: menu)
                    }
                }
            } else {
                // 로딩 중인 경우의 스켈레톤 UI
                ForEach(0..<3, id: \.self) { _ in
                    HStack {
                        Rectangle()
                            .fill(CLColor.SwiftUI.surface)
                            .frame(width: 80, height: 80)
                            .cornerRadius(8)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Rectangle()
                                .fill(CLColor.SwiftUI.surface)
                                .frame(height: 20)
                                .cornerRadius(4)
                            
                            Rectangle()
                                .fill(CLColor.SwiftUI.surface)
                                .frame(height: 16)
                                .cornerRadius(4)
                            
                            Rectangle()
                                .fill(CLColor.SwiftUI.surface)
                                .frame(height: 16)
                                .cornerRadius(4)
                                .frame(width: 100)
                        }
                        .padding(.leading, 8)
                    }
                    .padding(.vertical, 8)
                }
            }
        }
    }
    
    // 리뷰 컨텐츠
    private var reviewContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let foodTruck = detailViewModel.foodTruckDetail {
                // 리뷰 작성 버튼
                if userState.isLoggedIn {
                    Button {
                        showReviewForm = true
                    } label: {
                        Text("리뷰 작성하기")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(CLColor.SwiftUI.primaryColor)
                            .cornerRadius(8)
                    }
                    .padding(.bottom, 8)
                }
                
                if foodTruck.reviews.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "square.and.pencil")
                            .font(.system(size: 40))
                            .foregroundColor(CLColor.SwiftUI.textSecondary)
                            .padding(.top, 40)
                        
                        Text("아직 리뷰가 없습니다")
                            .font(.system(size: 16))
                            .foregroundColor(CLColor.SwiftUI.textSecondary)
                        
                        if userState.isLoggedIn {
                            Button {
                                showReviewForm = true
                            } label: {
                                Text("첫 리뷰 작성하기")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 12)
                                    .background(CLColor.SwiftUI.primaryColor)
                                    .cornerRadius(8)
                            }
                            .padding(.top, 8)
                        } else {
                            NavigationLink(destination: LoginView(userState: userState)) {
                                Text("로그인하고 리뷰 작성하기")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 12)
                                    .background(CLColor.SwiftUI.primaryColor)
                                    .cornerRadius(8)
                            }
                            .padding(.top, 8)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                } else {
                    ForEach(foodTruck.reviews) { review in
                        ReviewRow(review: review)
                    }
                }
            } else {
                // 로딩 중인 경우의 스켈레톤 UI
                ForEach(0..<3, id: \.self) { _ in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Rectangle()
                                .fill(CLColor.SwiftUI.surface)
                                .frame(width: 40, height: 40)
                                .cornerRadius(20)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Rectangle()
                                    .fill(CLColor.SwiftUI.surface)
                                    .frame(height: 16)
                                    .frame(width: 100)
                                    .cornerRadius(4)
                                
                                Rectangle()
                                    .fill(CLColor.SwiftUI.surface)
                                    .frame(height: 12)
                                    .frame(width: 60)
                                    .cornerRadius(4)
                            }
                            
                            Spacer()
                            
                            Rectangle()
                                .fill(CLColor.SwiftUI.surface)
                                .frame(width: 80, height: 20)
                                .cornerRadius(4)
                        }
                        
                        Rectangle()
                            .fill(CLColor.SwiftUI.surface)
                            .frame(height: 60)
                            .cornerRadius(4)
                    }
                    .padding(.vertical, 8)
                }
            }
        }
    }
}

// 메뉴 아이템 행
struct MenuItemRow: View {
    let menuItem: MenuItem
    
    var body: some View {
        HStack(spacing: 12) {
            // 이미지
            AsyncImage(url: URL(string: menuItem.imageUrl)) { phase in
                switch phase {
                case .empty:
                    Rectangle()
                        .fill(CLColor.SwiftUI.surface)
                        .frame(width: 80, height: 80)
                        .cornerRadius(8)
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 80)
                        .cornerRadius(8)
                        .clipped()
                case .failure:
                    Rectangle()
                        .fill(CLColor.SwiftUI.surface)
                        .frame(width: 80, height: 80)
                        .cornerRadius(8)
                        .overlay {
                            Image(systemName: "photo")
                                .foregroundColor(CLColor.SwiftUI.textSecondary)
                        }
                @unknown default:
                    Rectangle()
                        .fill(CLColor.SwiftUI.surface)
                        .frame(width: 80, height: 80)
                        .cornerRadius(8)
                }
            }
            
            // 정보
            VStack(alignment: .leading, spacing: 4) {
                Text(menuItem.name)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(CLColor.SwiftUI.textPrimary)
                
                if !menuItem.description.isEmpty {
                    Text(menuItem.description)
                        .font(.system(size: 14))
                        .foregroundColor(CLColor.SwiftUI.textSecondary)
                        .lineLimit(2)
                }
                
                Text(formatPrice(menuItem.price))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(CLColor.SwiftUI.primaryColor)
                    .padding(.top, 4)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
    
    // 가격 포맷 함수
    private func formatPrice(_ price: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return "\(formatter.string(from: NSNumber(value: price)) ?? "\(price)")원"
    }
}

// 리뷰 행
struct ReviewRow: View {
    let review: Review
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 상단 정보
            HStack {
                // 프로필 이미지 (기본 아이콘)
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 36))
                    .foregroundColor(CLColor.SwiftUI.textSecondary)
                
                // 사용자 정보
                VStack(alignment: .leading, spacing: 2) {
                    Text(review.authorName)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(CLColor.SwiftUI.textPrimary)
                    
                    if let date = review.createdAt.toFormattedDate() {
                        Text(date)
                            .font(.system(size: 12))
                            .foregroundColor(CLColor.SwiftUI.textSecondary)
                    }
                }
                
                Spacer()
                
                // 별점
                HStack(spacing: 2) {
                    ForEach(1...5, id: \.self) { rating in
                        Image(systemName: rating <= review.rating ? "star.fill" : "star")
                            .font(.system(size: 14))
                            .foregroundColor(CLColor.SwiftUI.accentColor)
                    }
                }
            }
            
            // 리뷰 내용
            Text(review.content)
                .font(.system(size: 15))
                .foregroundColor(CLColor.SwiftUI.textPrimary)
                .padding(.leading, 4)
            
            // 리뷰 이미지 (있을 경우)
            if !review.imageUrl.isEmpty {
                AsyncImage(url: URL(string: review.imageUrl)) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .fill(CLColor.SwiftUI.surface)
                            .frame(height: 160)
                            .cornerRadius(8)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 160)
                            .cornerRadius(8)
                            .clipped()
                    case .failure:
                        Rectangle()
                            .fill(CLColor.SwiftUI.surface)
                            .frame(height: 160)
                            .cornerRadius(8)
                            .overlay {
                                Image(systemName: "photo")
                                    .foregroundColor(CLColor.SwiftUI.textSecondary)
                            }
                    @unknown default:
                        Rectangle()
                            .fill(CLColor.SwiftUI.surface)
                            .frame(height: 160)
                            .cornerRadius(8)
                    }
                }
            }
            
            // 사장님 답변 (있을 경우)
            if !review.reply.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "bubble.left.fill")
                            .font(.system(size: 12))
                            .foregroundColor(CLColor.SwiftUI.primaryColor)
                        
                        Text("사장님 답변")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(CLColor.SwiftUI.primaryColor)
                    }
                    
                    Text(review.reply)
                        .font(.system(size: 14))
                        .foregroundColor(CLColor.SwiftUI.textPrimary)
                        .padding(.leading, 4)
                }
                .padding(12)
                .background(CLColor.SwiftUI.primaryColor.opacity(0.08))
                .cornerRadius(8)
            }
            
            Divider()
                .padding(.top, 8)
                .background(CLColor.SwiftUI.divider)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    NavigationView {
        FoodTruckDetailView(foodTruckId: 1, userState: UserState())
    }
}

