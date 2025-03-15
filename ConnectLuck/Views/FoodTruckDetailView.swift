//
//  FoodTruckDetailView.swift
//  ConnectLuck
//
//  Created by 이종민 on 3/14/25.
//

import SwiftUI

struct FoodTruckDetailView: View {
    let foodTruckId: Int
    @State private var viewModel = FoodTruckDetailViewModel()
    @State private var selectedTab = 0
    @State private var showReviewForm = false
    @Environment(UserState.self) private var userState

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                headerImage
                
                VStack(alignment: .leading, spacing: 16) {
                    basicInfo
                    Divider()
                        .background(CLColor.SwiftUI.divider)
                    tabSelection
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
                Button(action: { showReviewForm = true }) {
                    Label("리뷰 작성", systemImage: "square.and.pencil")
                        .foregroundColor(CLColor.SwiftUI.primaryColor)
                }
            }
        }
        .overlay(loadingIndicator)
        .task {
            await viewModel.fetchFoodTruckDetail(id: foodTruckId)
        }
        .alert(isPresented: Binding(
            get: { viewModel.showError },
            set: { viewModel.showError = $0 }
        )) {
            Alert(
                title: Text("데이터 로드 실패"),
                message: Text(viewModel.errorMessage ?? "오류가 발생했습니다."),
                dismissButton: .default(Text("확인"))
            )
        }
        .sheet(isPresented: $showReviewForm) {
            ReviewFormView()
        }
    }
}

// MARK: - 헤더 이미지
private extension FoodTruckDetailView {
    var headerImage: some View {
        ZStack(alignment: .bottomLeading) {
            if let foodTruck = viewModel.foodTruckDetail {
                AsyncImageView(url: foodTruck.imageUrl)
                FoodTypeTag(type: foodTruck.foodType)
                    .padding(16)
            } else {
                Rectangle()
                    .fill(CLColor.SwiftUI.surface)
                    .aspectRatio(16/9, contentMode: .fill)
                    .frame(height: 220)
            }
        }
    }
}

// MARK: - 기본 정보 섹션
private extension FoodTruckDetailView {
    var basicInfo: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let foodTruck = viewModel.foodTruckDetail {
                Text(foodTruck.name)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(CLColor.SwiftUI.textPrimary)
                
                HStack {
                    Text("운영자: \(foodTruck.managerName)")
                        .font(.system(size: 16))
                        .foregroundColor(CLColor.SwiftUI.textSecondary)
                    
                    Spacer()
                    
                    if let avgRating = foodTruck.avgRating {
                        // reviews는 non-optional 배열으로 가정
                        RatingView(rating: avgRating, reviewCount: foodTruck.reviews.count)
                    }
                }
                
                Text(foodTruck.description)
                    .font(.system(size: 16))
                    .foregroundColor(CLColor.SwiftUI.textPrimary)
                    .padding(.top, 4)
                
                // 현재 영업 상태 및 위치 보기
                HStack {
                    StatusBadge(status: .beforeApplication)
                    Spacer()
                    Button(action: { /* 위치 보기 액션 */ }) {
                        Label("위치 보기", systemImage: "map")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(CLColor.SwiftUI.primaryColor)
                    }
                }
                .padding(.top, 8)
                
                // 푸드트럭 관리자인 경우 추가 버튼 표시
                if userState.isFoodTruckManager && userState.currentUser?.name == foodTruck.managerName {
                    Button("영업 시작") {
                        // 영업 시작 액션
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .padding(.top, 16)
                }
            } else {
                SkeletonView()
            }
        }
    }
}

// MARK: - 탭 UI
private extension FoodTruckDetailView {
    var tabSelection: some View {
        HStack(spacing: 0) {
            ForEach(["메뉴", "리뷰"], id: \.self) { title in
                Button(action: { withAnimation { selectedTab = (title == "메뉴" ? 0 : 1) } }) {
                    VStack {
                        Text(title)
                            .font(.system(size: 16, weight: selectedTab == (title == "메뉴" ? 0 : 1) ? .semibold : .regular))
                            .foregroundColor(selectedTab == (title == "메뉴" ? 0 : 1) ? CLColor.SwiftUI.primaryColor : CLColor.SwiftUI.textSecondary)
                        if selectedTab == (title == "메뉴" ? 0 : 1) {
                            Rectangle().fill(CLColor.SwiftUI.primaryColor).frame(height: 2)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    var tabContent: some View {
        Group {
            if selectedTab == 0 {
                MenuListView(menus: viewModel.foodTruckDetail?.menus ?? [])
            } else {
                ReviewListView(reviews: viewModel.foodTruckDetail?.reviews ?? [])
            }
        }
    }
}

// MARK: - 로딩 인디케이터
private extension FoodTruckDetailView {
    var loadingIndicator: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
                    .frame(width: 100, height: 100)
                    .background(CLColor.SwiftUI.backgroundBase.opacity(0.7))
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
            }
        }
    }
}

//
// MARK: - 재사용 가능한 뷰 컴포넌트
//

struct AsyncImageView: View {
    let url: String
    
    var body: some View {
        AsyncImage(url: URL(string: url)) { phase in
            switch phase {
            case .empty:
                Rectangle()
                    .fill(CLColor.SwiftUI.surface)
                    .frame(height: 220)
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
                    .frame(height: 220)
                    .clipped()
            case .failure:
                Image(systemName: "photo")
                    .font(.system(size: 40))
                    .frame(height: 220)
                    .foregroundColor(CLColor.SwiftUI.textSecondary)
                    .background(CLColor.SwiftUI.surface)
            @unknown default:
                Rectangle()
                    .fill(CLColor.SwiftUI.surface)
                    .frame(height: 220)
            }
        }
    }
}

struct RatingView: View {
    let rating: Double
    let reviewCount: Int
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "star.fill")
                .foregroundColor(CLColor.SwiftUI.accentColor)
            Text(String(format: "%.1f", rating))
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(CLColor.SwiftUI.textPrimary)
            Text("(\(reviewCount))")
                .font(.system(size: 14))
                .foregroundColor(CLColor.SwiftUI.textSecondary)
        }
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(CLColor.SwiftUI.primaryColor)
            .cornerRadius(8)
            .opacity(configuration.isPressed ? 0.8 : 1)
    }
}

//
// MARK: - 더미 구현 (필요한 하위 뷰)
//

/// 리뷰 작성 폼 (추후 구현)
struct ReviewFormView: View {
    var body: some View {
        VStack {
            Text("리뷰 작성 폼")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(CLColor.SwiftUI.textPrimary)
                .padding()
            Text("이 기능은 추후 구현 예정입니다.")
                .font(.system(size: 16))
                .foregroundColor(CLColor.SwiftUI.textSecondary)
                .padding()
            Button("닫기") {
                // 닫기 액션은 sheet를 dismiss하는 방식으로 처리됨
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding()
        }
        .padding()
        .background(CLColor.SwiftUI.backgroundBase)
    }
}

/// 스켈레톤 뷰 (로딩 중 표시)
struct SkeletonView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
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
        .padding(.vertical, 16)
    }
}

/// 메뉴 리스트 뷰
struct MenuListView: View {
    let menus: [FoodTruckMenu]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if menus.isEmpty {
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
                ForEach(menus) { menu in
                    MenuItemRow(menu: menu)
                }
            }
        }
    }
}

/// 리뷰 리스트 뷰
struct ReviewListView: View {
    let reviews: [FoodTruckReview]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if reviews.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 40))
                        .foregroundColor(CLColor.SwiftUI.textSecondary)
                        .padding(.top, 40)
                    Text("아직 리뷰가 없습니다")
                        .font(.system(size: 16))
                        .foregroundColor(CLColor.SwiftUI.textSecondary)
                    
                    NavigationLink(destination: LoginView()) {
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
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                ForEach(reviews) { review in
                    ReviewRow(review: review)
                }
            }
        }
    }
}

//
// MARK: - 기타 재사용 가능한 뷰 컴포넌트
//

struct MenuItemRow: View {
    let menu: FoodTruckMenu
    
    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: menu.imageUrl)) { phase in
                switch phase {
                case .empty:
                    Rectangle()
                        .fill(CLColor.SwiftUI.surface)
                        .frame(width: 80, height: 80)
                        .cornerRadius(12)
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 80)
                        .cornerRadius(12)
                        .clipped()
                case .failure:
                    Rectangle()
                        .fill(CLColor.SwiftUI.surface)
                        .frame(width: 80, height: 80)
                        .cornerRadius(12)
                        .overlay {
                            Image(systemName: "photo")
                                .foregroundColor(CLColor.SwiftUI.textSecondary)
                        }
                @unknown default:
                    Rectangle()
                        .fill(CLColor.SwiftUI.surface)
                        .frame(width: 80, height: 80)
                        .cornerRadius(12)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(menu.name)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(CLColor.SwiftUI.textPrimary)
                if !menu.description.isEmpty {
                    Text(menu.description)
                        .font(.system(size: 14))
                        .foregroundColor(CLColor.SwiftUI.textSecondary)
                        .lineLimit(2)
                }
                Text(formatPrice(menu.price))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(CLColor.SwiftUI.primaryColor)
                    .padding(.top, 4)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
    
    private func formatPrice(_ price: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return "\(formatter.string(from: NSNumber(value: price)) ?? "\(price)")원"
    }
}

struct ReviewRow: View {
    let review: FoodTruckReview
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 36))
                    .foregroundColor(CLColor.SwiftUI.textSecondary)
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
                HStack(spacing: 2) {
                    ForEach(1...5, id: \.self) { rating in
                        Image(systemName: rating <= review.rating ? "star.fill" : "star")
                            .font(.system(size: 14))
                            .foregroundColor(CLColor.SwiftUI.accentColor)
                    }
                }
            }
            
            Text(review.content)
                .font(.system(size: 15))
                .foregroundColor(CLColor.SwiftUI.textPrimary)
                .padding(.leading, 4)
            
            if let imageUrl = review.imageUrl, !imageUrl.isEmpty {
                AsyncImage(url: URL(string: imageUrl)) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .fill(CLColor.SwiftUI.surface)
                            .frame(height: 160)
                            .cornerRadius(12)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 160)
                            .cornerRadius(12)
                            .clipped()
                    case .failure:
                        Rectangle()
                            .fill(CLColor.SwiftUI.surface)
                            .frame(height: 160)
                            .cornerRadius(12)
                            .overlay {
                                Image(systemName: "photo")
                                    .foregroundColor(CLColor.SwiftUI.textSecondary)
                            }
                    @unknown default:
                        Rectangle()
                            .fill(CLColor.SwiftUI.surface)
                            .frame(height: 160)
                            .cornerRadius(12)
                    }
                }
            }
            
            if let reply = review.reply, !reply.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "bubble.left.fill")
                            .font(.system(size: 12))
                            .foregroundColor(CLColor.SwiftUI.primaryColor)
                        Text("사장님 답변")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(CLColor.SwiftUI.primaryColor)
                    }
                    Text(reply)
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

//
// MARK: - Preview
//
#Preview {
    NavigationStack {
        FoodTruckDetailView(foodTruckId: 1)
            .environment(UserState())
    }
}
