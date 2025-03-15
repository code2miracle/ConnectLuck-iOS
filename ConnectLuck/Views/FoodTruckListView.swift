//
//  FoodTruckListView.swift
//  ConnectLuck
//
//  Created on 3/14/25.
//

import SwiftUI

struct FoodTruckListView: View {
    @State private var viewModel = FoodTruckViewModel()
    @State private var searchName: String = ""
    @State private var selectedFoodType: FoodType?
    @State private var isFilterSheetPresented = false
    @State private var isSearching = false
    @Environment(UserState.self) var userState
    
    var body: some View {
        NavigationView {
            ZStack {
                // 배경 색상
                CLColor.SwiftUI.backgroundBase.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // 검색바
                    searchBar
                    
                    // 필터 정보 표시
                    filterIndicator
                    
                    // 푸드트럭 목록
                    foodTruckList
                }
                .navigationTitle("푸드트럭")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            isFilterSheetPresented = true
                        } label: {
                            Image(systemName: "slider.horizontal.3")
                                .foregroundColor(CLColor.SwiftUI.textPrimary)
                        }
                    }
                }
                
                // 로딩 인디케이터
                if viewModel.isLoading {
                    loadingOverlay
                }
            }
            .sheet(isPresented: $isFilterSheetPresented) {
                FilterSheetView(
                    selectedFoodType: $selectedFoodType,
                    onApply: {
                        Task {
                            await applyFilters()
                        }
                    },
                    onReset: {
                        selectedFoodType = nil
                        Task {
                            await viewModel.fetchFoodTrucks()
                        }
                    }
                )
                .presentationDetents([.medium])
            }
            .task {
                // 앱 시작 시 데이터 로드
                await viewModel.fetchFoodTrucks()
            }
            .alert("데이터 로드 실패", isPresented: $viewModel.showError) {
                Button("확인", role: .cancel) {}
                Button("다시 시도") {
                    Task {
                        await viewModel.fetchFoodTrucks(
                            name: searchName.isEmpty ? nil : searchName,
                            foodType: selectedFoodType
                        )
                    }
                }
            } message: {
                Text(viewModel.errorMessage ?? "알 수 없는 오류가 발생했습니다.")
            }
        }
    }
    
    // MARK: - 컴포넌트
    
    private var searchBar: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(CLColor.SwiftUI.textSecondary)
                
                TextField("푸드트럭 이름 검색", text: $searchName)
                    .font(.system(size: 16)) // 디자인 가이드의 본문 사이즈
                    .foregroundColor(CLColor.SwiftUI.textPrimary)
                    .onSubmit {
                        isSearching = true
                        Task {
                            await applyFilters()
                            isSearching = false
                        }
                    }
                
                if !searchName.isEmpty {
                    Button {
                        searchName = ""
                        if !isSearching {
                            Task {
                                await applyFilters()
                            }
                        }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(CLColor.SwiftUI.textSecondary)
                    }
                }
            }
            .padding(12)
            .background(CLColor.SwiftUI.surface)
            .cornerRadius(8) // 중간 카드 코너 반경 8pt
        }
        .padding(.horizontal, 16) // 화면 가장자리 여백 16pt
        .padding(.top, 16)
        .padding(.bottom, 12)
    }
    
    private var filterIndicator: some View {
        VStack(spacing: 0) {
            if selectedFoodType != nil {
                HStack {
                    Text("필터:")
                        .font(.system(size: 12)) // 디자인 가이드의 캡션 스타일
                        .foregroundColor(CLColor.SwiftUI.textSecondary)
                    
                    if let type = selectedFoodType {
                        FilterChip(
                            label: type.displayName,
                            onRemove: {
                                selectedFoodType = nil
                                Task {
                                    await applyFilters()
                                }
                            }
                        )
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(CLColor.SwiftUI.surface.opacity(0.5))
            }
            
            Divider()
                .background(CLColor.SwiftUI.divider)
        }
    }
    
    private var foodTruckList: some View {
        ScrollView {
            LazyVStack(spacing: 16) { // 요소 간 간격 16pt
                if viewModel.foodTrucks.isEmpty && !viewModel.isLoading {
                    emptyStateView
                } else {
                    ForEach(viewModel.foodTrucks, id: \.id) { truck in
                        NavigationLink(destination: FoodTruckDetailView(foodTruckId: truck.id)) {
                            FoodTruckCard(truck: truck)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.bottom, 20)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
        }
        .refreshable {
            await viewModel.fetchFoodTrucks(
                name: searchName.isEmpty ? nil : searchName,
                foodType: selectedFoodType
            )
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "truck.box")
                .font(.system(size: 60))
                .foregroundColor(CLColor.SwiftUI.textSecondary)
            
            Text("검색 결과가 없습니다")
                .font(.system(size: 20, weight: .semibold)) // 헤드라인3 스타일
                .foregroundColor(CLColor.SwiftUI.textPrimary)
            
            Text("다른 검색어나 필터를 사용해보세요")
                .font(.system(size: 14)) // 본문 작게 스타일
                .foregroundColor(CLColor.SwiftUI.textSecondary)
                .multilineTextAlignment(.center)
            
            PrimaryButton(text: "모든 푸드트럭 보기") {
                searchName = ""
                selectedFoodType = nil
                Task {
                    await viewModel.fetchFoodTrucks()
                }
            }
            .padding(.top, 8)
            .frame(maxWidth: 240) // 버튼 너비 제한
        }
        .padding()
        .frame(maxWidth: .infinity)
        .padding(.top, 40)
    }
    
    private var loadingOverlay: some View {
        ZStack {
            CLColor.SwiftUI.backgroundBase.opacity(0.7)
            
            VStack(spacing: 15) {
                ProgressView()
                    .scaleEffect(1.5)
                
                Text("로딩 중...")
                    .font(.system(size: 16, weight: .medium)) // 본문 스타일
                    .foregroundColor(CLColor.SwiftUI.textSecondary)
            }
            .padding(24)
            .background(CLColor.SwiftUI.backgroundBase)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
        }
        .ignoresSafeArea()
    }
    
    // MARK: - 메서드
    
    private func applyFilters() async {
        await viewModel.fetchFoodTrucks(
            name: searchName.isEmpty ? nil : searchName,
            foodType: selectedFoodType
        )
    }
}

// MARK: - 보조 뷰

struct FoodTruckCard: View {
    let truck: FoodTruck
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 이미지
            ZStack(alignment: .bottomTrailing) {
                AsyncImage(url: URL(string: truck.imageUrl)) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .fill(CLColor.SwiftUI.surface)
                            .aspectRatio(16/9, contentMode: .fill)
                            .frame(height: 180)
                            .cornerRadius(12)
                            .overlay {
                                ProgressView()
                            }
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 180)
                            .cornerRadius(12)
                            .clipped()
                    case .failure:
                        Rectangle()
                            .fill(CLColor.SwiftUI.surface)
                            .aspectRatio(16/9, contentMode: .fill)
                            .frame(height: 180)
                            .cornerRadius(12)
                            .overlay {
                                Image(systemName: "photo")
                                    .font(.system(size: 24))
                                    .foregroundColor(CLColor.SwiftUI.textSecondary)
                            }
                    @unknown default:
                        Rectangle()
                            .fill(CLColor.SwiftUI.surface)
                            .aspectRatio(16/9, contentMode: .fill)
                            .frame(height: 180)
                            .cornerRadius(12)
                    }
                }
                
                // 푸드 타입 배지
                if let foodTypeEnum = truck.foodTypeEnum {
                    FoodTypeTag(type: foodTypeEnum.displayName)
                        .padding(10)
                }
            }
            
            // 정보
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(truck.name)
                        .font(.system(size: 18, weight: .semibold)) // 서브헤드 스타일
                        .foregroundColor(CLColor.SwiftUI.textPrimary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 12))
                            .foregroundColor(CLColor.SwiftUI.accentColor)
                        
                        Text(String(format: "%.1f", truck.avgRating))
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(CLColor.SwiftUI.textPrimary)
                        
                        Text("(\(truck.reviewCount))")
                            .font(.system(size: 12))
                            .foregroundColor(CLColor.SwiftUI.textSecondary)
                    }
                }
                
                Text(truck.description)
                    .font(.system(size: 14)) // 본문 작게 스타일
                    .foregroundColor(CLColor.SwiftUI.textSecondary)
                    .lineLimit(2)
                
                HStack {
                    Text("운영자: \(truck.managerName)")
                        .font(.system(size: 12)) // 캡션 스타일
                        .foregroundColor(CLColor.SwiftUI.textSecondary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    // 현재 영업 상태 표시 (예: "영업중", "모집중" 등)
                    StatusBadge(status: FoodTruckStatus.recruiting)
                }
                .padding(.top, 4)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(CLColor.SwiftUI.backgroundBase)
        .cornerRadius(12) // 큰 카드 코너 반경 12pt
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

struct FilterChip: View {
    let label: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Text(label)
                .font(.system(size: 12)) // 캡션 스타일
                .padding(.leading, 8)
                .padding(.vertical, 4)
            
            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.system(size: 10))
                    .padding(4)
            }
        }
        .background(CLColor.SwiftUI.primaryColor.opacity(0.1))
        .foregroundColor(CLColor.SwiftUI.primaryColor)
        .cornerRadius(12)
    }
}

struct FilterSheetView: View {
    @Binding var selectedFoodType: FoodType?
    let onApply: () -> Void
    let onReset: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    // 카테고리별로 FoodType 그룹화
    private let foodTypeGroups: [[FoodType]] = [
        // 한식/중식/일식 등 국가별 음식
        [.korean, .chinese, .japanese, .vietnamese, .indian, .thai, .turkish, .greek, .spanish, .italian, .mexican, .french, .brazilian, .americanSpecial],
        // 패스트푸드/스트릿푸드 류
        [.burger, .chicken, .hotdog, .pizza, .sandwich, .tacos, .burritos, .fishTacos, .friedChicken, .foodTruckSpecial, .streetFood, .bbq, .grilledCheese],
        // 기타 종류
        [.dessert, .drink, .noodle, .rice, .salad, .snack, .soup, .steak, .sushi, .brunch, .bakery, .coffeeShop, .bar, .vegetarian, .western, .iceCream, .etc]
    ]
    
    private let groupTitles = ["국가별 음식", "패스트푸드/스트릿푸드", "기타 종류"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(Array(foodTypeGroups.enumerated()), id: \.0) { index, group in
                        Section {
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100, maximum: 120))], spacing: 12) {
                                ForEach(group, id: \.self) { type in
                                    FoodTypeButton(
                                        type: type,
                                        isSelected: selectedFoodType == type,
                                        onTap: {
                                            if selectedFoodType == type {
                                                selectedFoodType = nil
                                            } else {
                                                selectedFoodType = type
                                            }
                                        }
                                    )
                                }
                            }
                        } header: {
                            Text(groupTitles[index])
                                .font(.system(size: 18, weight: .semibold)) // 서브헤드 스타일
                                .foregroundColor(CLColor.SwiftUI.textPrimary)
                                .padding(.vertical, 8)
                        }
                    }
                }
                .padding(16)
            }
            .background(CLColor.SwiftUI.backgroundBase)
            .navigationTitle("필터")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    TextButton(text: "초기화") {
                        onReset()
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    PrimaryButton(text: "적용", height: 36) {
                        onApply()
                        dismiss()
                    }
                    .frame(width: 80)
                }
            }
        }
    }
}

struct FoodTypeButton: View {
    let type: FoodType
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack {
                Text(type.displayName)
                    .font(.system(size: 14)) // 본문 작게 스타일
                    .padding(.horizontal, 8)
                    .padding(.vertical, 10)
                    .multilineTextAlignment(.center)
                    .frame(minHeight: 44)
                    .frame(maxWidth: .infinity)
            }
            .background(isSelected ? CLColor.SwiftUI.primaryColor.opacity(0.1) : CLColor.SwiftUI.surface)
            .foregroundColor(isSelected ? CLColor.SwiftUI.primaryColor : CLColor.SwiftUI.textPrimary)
            .cornerRadius(8) // 중간 카드 코너 반경 8pt
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? CLColor.SwiftUI.primaryColor : Color.clear, lineWidth: 1)
            )
        }
    }
}

// 디자인 시스템의 버튼들 구현
struct PrimaryButton: View {
    var text: String
    var height: CGFloat = 48
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.system(size: 16, weight: .semibold)) // 버튼 텍스트 스타일
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: height)
                .background(CLColor.SwiftUI.primaryColor)
                .cornerRadius(8)
        }
    }
}

struct SecondaryButton: View {
    var text: String
    var height: CGFloat = 48
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(CLColor.SwiftUI.primaryColor)
                .frame(maxWidth: .infinity)
                .frame(height: height)
                .background(CLColor.SwiftUI.backgroundBase)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(CLColor.SwiftUI.primaryColor, lineWidth: 1)
                )
                .cornerRadius(8)
        }
    }
}

struct TextButton: View {
    var text: String
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(CLColor.SwiftUI.primaryColor)
                .padding(.vertical, 8)
                .padding(.horizontal, 4)
        }
    }
}

// MARK: - 미리보기
#Preview {
    FoodTruckListView()
}
