//
//  EventListView.swift
//  ConnectLuck
//
//  Created by 이종민 on 3/14/25.
//

import SwiftUI

struct EventListView: View {
    @State private var viewModel = EventViewModel()
    @State private var selectedStatus: EventStatus?
    @State private var isFilterSheetPresented = false
    @State private var isGridView = true // 기본값 그리드 뷰로 변경
    @State private var selectedCategory: EventCategory = .all
    @State private var searchText = ""
    @State private var isSearching = false
    @State private var scrollOffset: CGFloat = 0
    
    // 이벤트 카테고리 (추천, 신규, 인기 등)
    enum EventCategory: String, CaseIterable, Identifiable {
        case all = "전체"
        case trending = "인기 행사"
        case upcoming = "신규 행사"
        case nearby = "내 주변"
        case food = "푸드 페스티벌"
        case music = "음악 행사"
        case art = "예술 전시"
        
        var id: String { self.rawValue }
    }
    
    // 더미 배너 데이터 (실제로는 서버에서 받아오는 것이 좋음)
    private let banners = [
        BannerData(id: 1, title: "서울 푸드 페스티벌", subtitle: "다양한 푸드트럭을 만나보세요", imageUrl: "https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=800&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8Zm9vZCUyMGZlc3RpdmFsfGVufDB8fDB8fHww"),
        BannerData(id: 2, title: "봄 꽃 축제", subtitle: "4월 한정 진행되는 특별 행사", imageUrl: "https://images.unsplash.com/photo-1496661415325-ef852f9e8e7c?w=800&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8N3x8Zmxvd2VyJTIwZmVzdGl2YWx8ZW58MHx8MHx8fDA%3D"),
        BannerData(id: 3, title: "대학 푸드트럭 행사", subtitle: "캠퍼스에서 만나는 다양한 음식", imageUrl: "https://images.unsplash.com/photo-1565123409695-7b5ef63a2efb?w=800&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTB8fGZvb2QlMjB0cnVja3xlbnwwfHwwfHx8MA%3D%3D")
    ]
    
    // 필터링된 행사 목록
    private var filteredEvents: [Event] {
        var events = viewModel.events
        
        // 상태 필터 적용
        if let status = selectedStatus {
            events = events.filter { $0.status == status }
        }
        
        // 카테고리 필터 적용 (더미 구현, 실제로는 서버에서 필터링 또는 로컬 데이터에 카테고리 속성이 있어야 함)
        switch selectedCategory {
        case .all:
            break // 모든 이벤트 표시
        case .trending:
            // 인기 행사는 리뷰가 많은 행사로 가정 (현재 데이터에 없으므로 더미 필터링)
            events = events.filter { $0.id.hashValue % 3 == 0 }
        case .upcoming:
            // 신규 행사는 시작일이 가까운 행사로 가정
            events = events.filter { $0.status == .beforeApplication || $0.status == .openForApplication }
        case .nearby:
            // 내 주변 행사는 특정 지역 행사로 가정
            events = events.filter { $0.address.contains("서울") || $0.address.contains("경기") }
        case .food:
            // 푸드 페스티벌은 제목이나 내용에 "푸드", "음식", "맛" 등의 키워드가 있는 행사로 가정
            events = events.filter {
                $0.title.contains("푸드") || $0.title.contains("음식") || $0.content.contains("맛") ||
                $0.title.contains("먹거리") || $0.title.contains("쿠킹")
            }
        case .music:
            // 음악 행사는 제목이나 내용에 "음악", "공연", "페스티벌" 등의 키워드가 있는 행사로 가정
            events = events.filter {
                $0.title.contains("음악") || $0.title.contains("공연") || $0.content.contains("페스티벌") ||
                $0.title.contains("콘서트") || $0.title.contains("밴드")
            }
        case .art:
            // 예술 전시는 제목이나 내용에 "예술", "전시", "미술" 등의 키워드가 있는 행사로 가정
            events = events.filter {
                $0.title.contains("예술") || $0.title.contains("전시") || $0.content.contains("미술") ||
                $0.title.contains("작품") || $0.title.contains("갤러리")
            }
        }
        
        // 검색어 필터 적용
        if !searchText.isEmpty {
            events = events.filter { $0.title.localizedCaseInsensitiveContains(searchText) ||
                                    $0.content.localizedCaseInsensitiveContains(searchText) }
        }
        
        return events
    }

    var body: some View {
        ZStack(alignment: .top) {
            // 배경 색상
            CLColor.SwiftUI.backgroundBase.ignoresSafeArea()
            
            // 이벤트 목록 콘텐츠
            VStack(spacing: 0) {
                // 헤더 및 검색바
                headerSection
                
                ScrollView {
                    // 오프셋 트래킹
                    GeometryReader { proxy in
                        Color.clear.preference(
                            key: ScrollOffsetPreferenceKey.self,
                            value: proxy.frame(in: .named("scrollView")).origin.y
                        )
                    }
                    .frame(height: 0)
                    
                    VStack(spacing: 0) {
                        // 배너 섹션
                        if !isSearching && selectedStatus == nil {
                            bannerSection
                                .padding(.top, 16)
                        }
                        
                        // 카테고리 필터 섹션
                        categoryFilterSection
                            .padding(.top, 16)
                        
                        // 이벤트 목록 섹션
                        eventListSection
                    }
                }
                .coordinateSpace(name: "scrollView")
                .refreshable {
                    await viewModel.fetchEvents(status: selectedStatus)
                }
                .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                    scrollOffset = value
                }
            }
            
            // 검색 오버레이 (검색 중일 때만 표시)
            if isSearching {
                searchOverlay
            }
            
            // 로딩 인디케이터
            if viewModel.isLoading {
                loadingOverlay
            }
        }
        .navigationTitle("행사")
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
            
            // 그리드/리스트 뷰 토글 버튼
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    withAnimation {
                        isGridView.toggle()
                    }
                } label: {
                    Image(systemName: isGridView ? "list.bullet" : "square.grid.2x2")
                        .foregroundColor(CLColor.SwiftUI.textPrimary)
                }
            }
        }
        .sheet(isPresented: $isFilterSheetPresented) {
            // 상태 필터 시트
            EventFilterSheetView(
                selectedStatus: $selectedStatus,
                onApply: {
                    Task {
                        await applyFilters()
                    }
                },
                onReset: {
                    selectedStatus = nil
                    Task {
                        await viewModel.fetchEvents()
                    }
                }
            )
            .presentationDetents([.medium])
        }
        .task {
            // 앱 시작 시 전체 이벤트 목록 로드
            await viewModel.fetchEvents()
        }
        .alert(isPresented: $viewModel.showError) {
            Alert(
                title: Text("데이터 로드 실패"),
                message: Text(viewModel.errorMessage ?? "알 수 없는 오류가 발생했습니다."),
                dismissButton: .default(Text("확인"))
            )
        }
    }
}

// MARK: - 헤더 섹션
private extension EventListView {
    var headerSection: some View {
        VStack(spacing: 12) {
            // 검색바
            HStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(CLColor.SwiftUI.textSecondary)
                    
                    TextField("행사 검색", text: $searchText, onEditingChanged: { isEditing in
                        withAnimation {
                            isSearching = isEditing
                        }
                    })
                    .font(.system(size: 16))
                    .foregroundColor(CLColor.SwiftUI.textPrimary)
                    
                    if !searchText.isEmpty {
                        Button {
                            searchText = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(CLColor.SwiftUI.textSecondary)
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
            }
            .padding(.horizontal, 16)
            
            // 적용된 필터 표시 칩
            if selectedStatus != nil {
                HStack {
                    if let status = selectedStatus {
                        FilterChip(
                            label: status.displayText,
                            onRemove: {
                                selectedStatus = nil
                                Task {
                                    await applyFilters()
                                }
                            }
                        )
                    }
                    Spacer()
                }
                .padding(.horizontal, 16)
            }
        }
        .padding(.top, 8)
        .padding(.bottom, 8)
        .background(CLColor.SwiftUI.backgroundBase)
        .shadow(color: Color.black.opacity(scrollOffset < -10 ? 0.1 : 0), radius: 4, x: 0, y: 2)
        .zIndex(1)
    }
}

// MARK: - 배너 섹션
private extension EventListView {
    var bannerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("주목할 행사")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(CLColor.SwiftUI.textPrimary)
                .padding(.horizontal, 16)
            
            TabView {
                ForEach(banners) { banner in
                    BannerCard(data: banner)
                        .padding(.horizontal, 16)
                }
            }
            .frame(height: 180)
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
        }
    }
}

// MARK: - 카테고리 필터 섹션
private extension EventListView {
    var categoryFilterSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(EventCategory.allCases) { category in
                        CategoryButton(
                            name: category.rawValue,
                            isSelected: selectedCategory == category,
                            action: {
                                withAnimation {
                                    selectedCategory = category
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal, 16)
            }
            
            // 결과 수 표시
            if filteredEvents.isEmpty {
                Text("검색 결과가 없습니다")
                    .font(.system(size: 14))
                    .foregroundColor(CLColor.SwiftUI.textSecondary)
                    .padding(.horizontal, 16)
                    .padding(.top, 4)
            } else if selectedCategory != .all || !searchText.isEmpty || selectedStatus != nil {
                Text("\(filteredEvents.count)개의 행사")
                    .font(.system(size: 14))
                    .foregroundColor(CLColor.SwiftUI.textSecondary)
                    .padding(.horizontal, 16)
                    .padding(.top, 4)
            }
        }
    }
}

// MARK: - 모던 이벤트 그리드 카드
struct ModernEventGridCard: View {
    let event: Event
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 이미지 컨테이너
            ZStack(alignment: .topTrailing) {
                AsyncImage(url: URL(string: event.imageUrl)) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .fill(CLColor.SwiftUI.surface)
                            .frame(height: 120)
                            .cornerRadius(12)
                            .overlay {
                                ProgressView()
                            }
                    case .success(let image):
                        image
                            .resizable()
                            .cornerRadius(12)
                            .aspectRatio(contentMode: .fit)
                            .clipped()
                    case .failure:
                        Rectangle()
                            .fill(CLColor.SwiftUI.surface)
                            .frame(height: 120)
                            .cornerRadius(12)
                            .overlay {
                                Image(systemName: "photo")
                                    .font(.system(size: 24))
                                    .foregroundColor(CLColor.SwiftUI.textSecondary)
                            }
                    @unknown default:
                        Rectangle()
                            .fill(CLColor.SwiftUI.surface)
                            .frame(height: 120)
                            .cornerRadius(12)
                    }
                }
                
                // 상태 배지 - 작게 조정
                StatusBadge(status: event.status)
                    .padding([.top, .trailing], 6)
            }
            
            // 이벤트 정보
            VStack(alignment: .leading, spacing: 2) {
                // 제목
                Text(event.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(CLColor.SwiftUI.textPrimary)
                    .lineLimit(1)
                
                // 날짜
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.system(size: 10))
                        .foregroundColor(CLColor.SwiftUI.textSecondary)
                    
                    Text(event.dateRange.components(separatedBy: " ~ ").first ?? "")
                        .font(.system(size: 10))
                        .foregroundColor(CLColor.SwiftUI.textSecondary)
                        .lineLimit(1)
                }
                .padding(.top, 2)
                
                // 장소
                HStack(spacing: 4) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 10))
                        .foregroundColor(CLColor.SwiftUI.textSecondary)
                    
                    let address = event.address.components(separatedBy: " ")
                    Text(address.count > 2 ? "\(address[0]) \(address[1])" : event.address)
                        .font(.system(size: 10))
                        .foregroundColor(CLColor.SwiftUI.textSecondary)
                        .lineLimit(1)
                }
                .padding(.top, 1)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

// MARK: - 이벤트 목록 섹션
private extension EventListView {
    var eventListSection: some View {
        VStack(spacing: 0) {
            if filteredEvents.isEmpty {
                emptyStateView
            } else {
                if isGridView {
                    // 그리드 뷰
                    LazyVGrid(
                        columns: [GridItem(.adaptive(minimum: UIScreen.main.bounds.width > 390 ? 180 : 160))],
                        spacing: 16
                    ) {
                        ForEach(filteredEvents) { event in
                            NavigationLink(destination: EventDetailView(eventId: Int(event.id))) {
                                ModernEventGridCard(event: event)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(16)
                } else {
                    // 리스트 뷰
                    LazyVStack(spacing: 16) {
                        ForEach(filteredEvents) { event in
                            NavigationLink(destination: EventDetailView(eventId: Int(event.id))) {
                                ModernEventListCard(event: event)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(16)
                }
            }
            
            // 하단 여백
            Spacer()
                .frame(height: 40)
        }
    }
}

// MARK: - 검색 오버레이
private extension EventListView {
    var searchOverlay: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 검색 결과 헤더
            HStack {
                Button {
                    searchText = ""
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    withAnimation {
                        isSearching = false
                    }
                } label: {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(CLColor.SwiftUI.textPrimary)
                        .padding(10)
                        .background(CLColor.SwiftUI.surface)
                        .cornerRadius(8)
                }
                
                Spacer()
                
                Text("검색 결과")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(CLColor.SwiftUI.textPrimary)
                    .padding(.trailing, 16)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 65) // 검색바 아래에 위치하도록 조정
            
            if searchText.isEmpty {
                // 추천 검색어
                VStack(alignment: .leading, spacing: 16) {
                    Text("추천 검색어")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(CLColor.SwiftUI.textPrimary)
                    
                    FlowLayout(spacing: 12) {
                        ForEach(["푸드 페스티벌", "음악 공연", "전시회", "마켓", "지역 축제", "봄 축제", "플리마켓"], id: \.self) { term in
                            Button {
                                searchText = term
                            } label: {
                                Text(term)
                                    .font(.system(size: 14))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(CLColor.SwiftUI.surface)
                                    .foregroundColor(CLColor.SwiftUI.textPrimary)
                                    .cornerRadius(16)
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
            } else if filteredEvents.isEmpty {
                // 검색 결과 없음
                VStack(spacing: 24) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 50))
                        .foregroundColor(CLColor.SwiftUI.textSecondary.opacity(0.6))
                        .padding(.top, 40)
                    
                    Text("'\(searchText)'에 대한 검색 결과가 없습니다")
                        .font(.system(size: 16))
                        .foregroundColor(CLColor.SwiftUI.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    
                    Text("다른 키워드로 검색해보세요")
                        .font(.system(size: 14))
                        .foregroundColor(CLColor.SwiftUI.textSecondary)
                }
                .frame(maxWidth: .infinity)
            } else {
                // 검색 결과 표시
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(filteredEvents) { event in
                            NavigationLink(destination: EventDetailView(eventId: Int(event.id))) {
                                ModernEventListCard(event: event)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(16)
                }
            }
        }
        .background(CLColor.SwiftUI.backgroundBase)
        .edgesIgnoringSafeArea(.top)
    }
}

// MARK: - Empty State View
private extension EventListView {
    var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 60))
                .foregroundColor(CLColor.SwiftUI.textSecondary.opacity(0.6))
                .padding(.top, 60)

            Text("조건에 맞는 행사가 없습니다")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(CLColor.SwiftUI.textPrimary)

            Text("필터를 변경하거나 다른 카테고리를 선택해보세요")
                .font(.system(size: 14))
                .foregroundColor(CLColor.SwiftUI.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Button {
                selectedStatus = nil
                selectedCategory = .all
                searchText = ""
                Task {
                    await viewModel.fetchEvents()
                }
            } label: {
                Text("모든 행사 보기")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(minWidth: 180)
                    .padding(.vertical, 14)
                    .background(CLColor.SwiftUI.primaryColor)
                    .cornerRadius(10)
            }
            .padding(.top, 8)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .padding(.top, 40)
    }
}

// MARK: - 로딩 오버레이
private extension EventListView {
    var loadingOverlay: some View {
        ZStack {
            CLColor.SwiftUI.backgroundBase.opacity(0.7)
            
            VStack(spacing: 15) {
                ProgressView()
                    .scaleEffect(1.2)
                
                Text("로딩 중...")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(CLColor.SwiftUI.textSecondary)
            }
            .padding(24)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
        }
        .ignoresSafeArea()
    }
}

// MARK: - 필터 적용 함수
private extension EventListView {
    func applyFilters() async {
        await viewModel.fetchEvents(status: selectedStatus)
    }
}

// MARK: - 카테고리 버튼
struct CategoryButton: View {
    let name: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(name)
                .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(isSelected ? CLColor.SwiftUI.primaryColor : Color.white)
                .foregroundColor(isSelected ? .white : CLColor.SwiftUI.textPrimary)
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(isSelected ? 0.1 : 0.05), radius: 3, x: 0, y: 1)
        }
    }
}

// MARK: - 배너 카드
struct BannerCard: View {
    let data: BannerData
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            AsyncImage(url: URL(string: data.imageUrl)) { phase in
                switch phase {
                case .empty:
                    Rectangle()
                        .fill(CLColor.SwiftUI.surface)
                        .frame(height: 180)
                        .cornerRadius(16)
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 180)
                        .cornerRadius(16)
                        .clipped()
                case .failure:
                    Rectangle()
                        .fill(CLColor.SwiftUI.surface)
                        .frame(height: 180)
                        .cornerRadius(16)
                        .overlay {
                            Image(systemName: "photo")
                                .font(.system(size: 24))
                                .foregroundColor(CLColor.SwiftUI.textSecondary)
                        }
                @unknown default:
                    Rectangle()
                        .fill(CLColor.SwiftUI.surface)
                        .frame(height: 180)
                        .cornerRadius(16)
                }
            }
            
            // 그라데이션 오버레이
            LinearGradient(
                gradient: Gradient(colors: [Color.black.opacity(0.6), Color.black.opacity(0.0)]),
                startPoint: .bottom,
                endPoint: .top
            )
            .frame(height: 180)
            .cornerRadius(16)
            
            // 배너 텍스트
            VStack(alignment: .leading, spacing: 4) {
                Text(data.title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                Text(data.subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.9))
            }
            .padding(16)
        }
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}


struct ModernEventListCard: View {
    let event: Event
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // 이미지 컨테이너
            ZStack(alignment: .topTrailing) {
                AsyncImage(url: URL(string: event.imageUrl)) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .fill(CLColor.SwiftUI.surface)
                            .frame(width: 120, height: 120)
                            .cornerRadius(12)
                            .overlay {
                                ProgressView()
                            }
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 120, height: 120)
                            .cornerRadius(12)
                            .clipped()
                    case .failure:
                        Rectangle()
                            .fill(CLColor.SwiftUI.surface)
                            .frame(width: 120, height: 120)
                            .cornerRadius(12)
                            .overlay {
                                Image(systemName: "photo")
                                    .font(.system(size: 24))
                                    .foregroundColor(CLColor.SwiftUI.textSecondary)
                            }
                    @unknown default:
                        Rectangle()
                            .fill(CLColor.SwiftUI.surface)
                            .frame(width: 120, height: 120)
                            .cornerRadius(12)
                    }
                }
                
                // 상태 배지 - 불투명한 배경으로 가독성 향상
                StatusBadge(status: event.status)
                    .padding([.top, .trailing], 8)
            }
            
            // 이벤트 정보
            VStack(alignment: .leading, spacing: 6) {
                // 제목
                Text(event.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(CLColor.SwiftUI.textPrimary)
                    .lineLimit(2)
                
                // 날짜와 장소
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .font(.system(size: 12))
                        .foregroundColor(CLColor.SwiftUI.textSecondary)
                    
                    Text(event.dateRange)
                        .font(.system(size: 12))
                        .foregroundColor(CLColor.SwiftUI.textSecondary)
                        .lineLimit(1)
                }
                
                HStack(spacing: 6) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 12))
                        .foregroundColor(CLColor.SwiftUI.textSecondary)
                    
                    Text(event.address)
                        .font(.system(size: 12))
                        .foregroundColor(CLColor.SwiftUI.textSecondary)
                        .lineLimit(1)
                }
                
                // 간략한 설명
                Text(event.content)
                    .font(.system(size: 12))
                    .foregroundColor(CLColor.SwiftUI.textSecondary)
                    .lineLimit(2)
                    .padding(.top, 4)
                
                Spacer()
            }
            .padding(.vertical, 4)
        }
        .padding(12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 2)
    }
}

// MARK: - 배너 데이터 모델
struct BannerData: Identifiable {
    let id: Int
    let title: String
    let subtitle: String
    let imageUrl: String
}

// MARK: - 스크롤 옵셋 트래킹을 위한 PreferenceKey
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - FlowLayout
struct FlowLayout: Layout {
    var spacing: CGFloat = 10
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) -> CGSize {
        let containerWidth = proposal.width ?? .infinity
        var height: CGFloat = 0
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        
        var rowWidth: CGFloat = 0
        var rowHeight: CGFloat = 0
        
        for (index, size) in sizes.enumerated() {
            if rowWidth + size.width > containerWidth && rowWidth > 0 {
                // 새 행 시작
                height += rowHeight + spacing
                rowWidth = size.width
                rowHeight = size.height
            } else {
                // 현재 행에 추가
                rowWidth += size.width + (index > 0 ? spacing : 0)
                rowHeight = max(rowHeight, size.height)
            }
        }
        
        height += rowHeight // 마지막 행의 높이 추가
        
        return CGSize(width: containerWidth, height: height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        
        var rowX: CGFloat = bounds.minX
        var rowY: CGFloat = bounds.minY
        var rowHeight: CGFloat = 0
        
        for (index, subview) in subviews.enumerated() {
            let size = sizes[index]
            
            if rowX + size.width > bounds.maxX && rowX > bounds.minX {
                // 새 행 시작
                rowX = bounds.minX
                rowY += rowHeight + spacing
                rowHeight = 0
            }
            
            // 현재 위치에 배치
            subview.place(
                at: CGPoint(x: rowX, y: rowY),
                proposal: ProposedViewSize(width: size.width, height: size.height)
            )
            
            rowX += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

struct EventFilterSheetView: View {
    @Binding var selectedStatus: EventStatus?
    let onApply: () -> Void
    let onReset: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    /// 이벤트 상태 목록
    private let statuses: [EventStatus] = [
        .beforeApplication,
        .openForApplication,
        .applicationFinished,
        .eventStart,
        .eventEnd
    ]
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                Text("상태별 필터")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(CLColor.SwiftUI.textPrimary)
                    .padding(.top, 16)
                
                Text("원하는 행사 진행 상태를 선택하세요")
                    .font(.system(size: 14))
                    .foregroundColor(CLColor.SwiftUI.textSecondary)
                
                VStack(spacing: 12) {
                    ForEach(statuses, id: \.self) { status in
                        Button {
                            if selectedStatus == status {
                                selectedStatus = nil
                            } else {
                                selectedStatus = status
                            }
                        } label: {
                            HStack {
                                StatusBadge(status: status)
                                
                                Text(status.displayText)
                                    .font(.system(size: 16))
                                    .foregroundColor(CLColor.SwiftUI.textPrimary)
                                
                                Spacer()
                                
                                if selectedStatus == status {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(CLColor.SwiftUI.primaryColor)
                                } else {
                                    Circle()
                                        .strokeBorder(CLColor.SwiftUI.divider, lineWidth: 1.5)
                                        .frame(width: 22, height: 22)
                                }
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(selectedStatus == status ? CLColor.SwiftUI.primaryColor.opacity(0.1) : Color.white)
                                    .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                            )
                        }
                    }
                }
                
                Spacer()
                
                // 하단 버튼들
                HStack(spacing: 12) {
                    Button {
                        onReset()
                        dismiss()
                    } label: {
                        Text("초기화")
                            .font(.system(size: 16, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .foregroundColor(CLColor.SwiftUI.textPrimary)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(CLColor.SwiftUI.divider, lineWidth: 1)
                                    .background(Color.white.cornerRadius(12))
                            )
                    }
                    
                    Button {
                        onApply()
                        dismiss()
                    } label: {
                        Text("적용하기")
                            .font(.system(size: 16, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .foregroundColor(.white)
                            .background(CLColor.SwiftUI.primaryColor)
                            .cornerRadius(12)
                    }
                }
                .padding(.bottom, 16)
            }
            .padding(.horizontal, 16)
            .background(CLColor.SwiftUI.backgroundBase)
            .navigationTitle("필터")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(CLColor.SwiftUI.textPrimary)
                    }
                }
            }
        }
    }
}



// MARK: - 옵셔널 확장
extension Optional {
    var isNil: Bool {
        self == nil
    }
}

#Preview {
    EventListView()
}
