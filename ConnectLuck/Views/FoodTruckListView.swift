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
    
    var body: some View {
        NavigationView {
            ZStack {
                // 배경 색상
                Color(.systemBackground).ignoresSafeArea()
                
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
                                .foregroundColor(.primary)
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
                    .foregroundColor(.gray)
                
                TextField("푸드트럭 이름 검색", text: $searchName)
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
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(10)
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
        .padding(.horizontal)
        .padding(.top, 8)
        .padding(.bottom, 8)
    }
    
    private var filterIndicator: some View {
        VStack(spacing: 0) {
            if selectedFoodType != nil {
                HStack {
                    Text("필터:")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    
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
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color(.systemGray6).opacity(0.5))
            }
            
            Divider()
        }
    }
    
    private var foodTruckList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
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
            .padding(.horizontal)
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
                .foregroundColor(.gray)
            
            Text("검색 결과가 없습니다")
                .font(.headline)
            
            Text("다른 검색어나 필터를 사용해보세요")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button {
                searchName = ""
                selectedFoodType = nil
                Task {
                    await viewModel.fetchFoodTrucks()
                }
            } label: {
                Text("모든 푸드트럭 보기")
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            .padding(.top, 10)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .padding(.top, 40)
    }
    
    private var loadingOverlay: some View {
        ZStack {
            Color(.systemBackground).opacity(0.7)
            
            VStack(spacing: 15) {
                ProgressView()
                    .scaleEffect(1.5)
                
                Text("로딩 중...")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
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
                            .fill(Color.gray.opacity(0.3))
                            .aspectRatio(16/9, contentMode: .fill)
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
                            .fill(Color.gray.opacity(0.3))
                            .aspectRatio(16/9, contentMode: .fill)
                            .cornerRadius(12)
                            .overlay {
                                Image(systemName: "photo")
                                    .font(.largeTitle)
                                    .foregroundColor(.gray)
                            }
                    @unknown default:
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .aspectRatio(16/9, contentMode: .fill)
                            .cornerRadius(12)
                    }
                }
                
                // 푸드 타입 배지
                if let foodTypeEnum = truck.foodTypeEnum {
                    Text(foodTypeEnum.displayName)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.black.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(6)
                        .padding(10)
                }
            }
            
            // 정보
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(truck.name)
                        .font(.headline)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundColor(.yellow)
                        
                        Text(String(format: "%.1f", truck.avgRating))
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        Text("(\(truck.reviewCount))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Text(truck.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                HStack {
                    Text("운영자: \(truck.managerName)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 4)
            }
            .padding(.horizontal, 4)
            .padding(.bottom, 8)
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct FilterChip: View {
    let label: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Text(label)
                .font(.caption)
                .padding(.leading, 8)
                .padding(.vertical, 4)
            
            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.caption)
                    .padding(4)
            }
        }
        .background(Color.blue.opacity(0.1))
        .foregroundColor(.blue)
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
                                .font(.headline)
                                .padding(.vertical, 8)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("필터")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("초기화") {
                        onReset()
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("적용") {
                        onApply()
                        dismiss()
                    }
                    .fontWeight(.semibold)
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
                    .font(.subheadline)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 10)
                    .multilineTextAlignment(.center)
                    .frame(minHeight: 44)
                    .frame(maxWidth: .infinity)
            }
            .background(isSelected ? Color.blue.opacity(0.1) : Color(.systemGray6))
            .foregroundColor(isSelected ? .blue : .primary)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
    }
}

// 푸드트럭 상세 뷰 스텁
struct FoodTruckDetailView: View {
    let foodTruckId: Int
    
    var body: some View {
        Text("푸드트럭 상세 정보 (ID: \(foodTruckId))")
            .navigationTitle("상세 정보")
    }
}

// MARK: - 미리보기
struct FoodTruckListView_Previews: PreviewProvider {
    static var previews: some View {
        FoodTruckListView()
    }
}
