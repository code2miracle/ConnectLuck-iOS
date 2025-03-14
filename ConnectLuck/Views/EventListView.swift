//
//  EventListView.swift
//  ConnectLuck
//
//  Created by 이종민 on 3/14/25.
//

import Foundation

class EventService {
    static let shared = EventService()
    
    /// 이벤트 목록 가져오기
    func fetchEvents(query: String? = nil, status: EventStatus? = nil) async throws -> [Event] {
        var queryItems: [URLQueryItem] = []
        
        if let query = query {
            queryItems.append(URLQueryItem(name: "q", value: query))
        }
        if let status = status {
            queryItems.append(URLQueryItem(name: "status", value: status.rawValue))
        }

        var endpoint = EndPoint.Event.list
        if !queryItems.isEmpty {
            let queryString = queryItems.map { "\($0.name)=\($0.value!)" }.joined(separator: "&")
            endpoint += "?\(queryString)"
        }
        
        print("API 요청: \(EndPoint.baseURL)\(endpoint)")
        return try await NetworkManager.shared.request(endpoint: endpoint)
    }
    
    /// 이벤트 상세 정보 가져오기
    func fetchEventDetail(id: Int) async throws -> Event {
        let endpoint = EndPoint.Event.detail(id)
        print("API 요청: \(EndPoint.baseURL)\(endpoint)")
        return try await NetworkManager.shared.request(endpoint: endpoint)
    }
}

// EventViewModel.swift

import Foundation
import Observation

@Observable
class EventViewModel {
    var events: [Event] = []
    var isLoading = false
    var errorMessage: String?
    var showError = false
    
    // 이벤트 목록 가져오기
    func fetchEvents(query: String? = nil, status: EventStatus? = nil) async {
        isLoading = true
        errorMessage = nil
        showError = false
        
        do {
            events = try await EventService.shared.fetchEvents(query: query, status: status)
            
            if events.isEmpty {
                print("API 응답: 검색 결과 없음")
            } else {
                print("API 응답: \(events.count)개의 이벤트 정보 로드됨")
            }
        } catch {
            errorMessage = "데이터를 불러오는 중 오류가 발생했습니다: \(error.localizedDescription)"
            showError = true
            print("API 오류: \(error.localizedDescription)")
            
            // 실패 시 디버그 모드에서는 더미 데이터 사용
            #if DEBUG
            if events.isEmpty {
                print("디버그 모드: 더미 데이터 로드")
                events = Event.dummyData()
            }
            #endif
        }
        
        isLoading = false
    }
}

// EventListView.swift

import SwiftUI

struct EventListView: View {
    @State private var viewModel = EventViewModel()
    @State private var searchText = ""
    @State private var selectedStatus: EventStatus?
    @State private var isFilterSheetPresented = false
    @State private var isSearching = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // 배경 색상
                CLColor.SwiftUI.backgroundBase.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // 검색바
                    HStack {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(CLColor.SwiftUI.textSecondary)
                            
                            TextField("행사 검색", text: $searchText)
                                .font(.system(size: 17))
                                .foregroundColor(CLColor.SwiftUI.textPrimary)
                                .onSubmit {
                                    isSearching = true
                                    Task {
                                        await applyFilters()
                                        isSearching = false
                                    }
                                }
                            
                            if !searchText.isEmpty {
                                Button {
                                    searchText = ""
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
                        .cornerRadius(8)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 12)
                    
                    // 필터 정보 표시
                    VStack(spacing: 0) {
                        if selectedStatus != nil {
                            HStack {
                                Text("필터:")
                                    .font(.system(size: 13))
                                    .foregroundColor(CLColor.SwiftUI.textSecondary)
                                
                                if let status = selectedStatus {
                                    HStack(spacing: 4) {
                                        Text(status.displayText)
                                            .font(.system(size: 13))
                                            .padding(.leading, 8)
                                            .padding(.vertical, 4)
                                        
                                        Button(action: {
                                            selectedStatus = nil
                                            Task {
                                                await applyFilters()
                                            }
                                        }) {
                                            Image(systemName: "xmark")
                                                .font(.system(size: 12))
                                                .padding(4)
                                        }
                                    }
                                    .background(CLColor.SwiftUI.primaryColor.opacity(0.1))
                                    .foregroundColor(CLColor.SwiftUI.primaryColor)
                                    .cornerRadius(12)
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
                    
                    // 이벤트 목록
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            if viewModel.events.isEmpty && !viewModel.isLoading {
                                emptyStateView
                            } else {
                                ForEach(viewModel.events) { event in
                                    NavigationLink(destination: EventDetailView(eventId: Int(event.id))) {
                                        EventListCard(event: event)
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
                        await viewModel.fetchEvents(
                            query: searchText.isEmpty ? nil : searchText,
                            status: selectedStatus
                        )
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
                }
                
                // 로딩 인디케이터
                if viewModel.isLoading {
                    loadingOverlay
                }
            }
            .sheet(isPresented: $isFilterSheetPresented) {
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
                // 앱 시작 시 데이터 로드
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
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 60))
                .foregroundColor(CLColor.SwiftUI.textSecondary)
            
            Text("검색 결과가 없습니다")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(CLColor.SwiftUI.textPrimary)
            
            Text("다른 검색어나 필터를 사용해보세요")
                .font(.system(size: 15))
                .foregroundColor(CLColor.SwiftUI.textSecondary)
                .multilineTextAlignment(.center)
            
            PrimaryButton(text: "모든 행사 보기") {
                searchText = ""
                selectedStatus = nil
                Task {
                    await viewModel.fetchEvents()
                }
            }
            .padding(.top, 8)
            .frame(maxWidth: 240)
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
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(CLColor.SwiftUI.textSecondary)
            }
        }
        .ignoresSafeArea()
    }
    
    private func applyFilters() async {
        await viewModel.fetchEvents(
            query: searchText.isEmpty ? nil : searchText,
            status: selectedStatus
        )
    }
}

// 이벤트 필터 시트
struct EventFilterSheetView: View {
    @Binding var selectedStatus: EventStatus?
    let onApply: () -> Void
    let onReset: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    private let statuses: [EventStatus] = [.recruiting, .comingSoon, .closed, .finished]
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                Text("상태별 필터")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(CLColor.SwiftUI.textPrimary)
                    .padding(.top, 16)
                
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
                                    Image(systemName: "checkmark")
                                        .foregroundColor(CLColor.SwiftUI.primaryColor)
                                }
                            }
                            .padding(12)
                            .background(selectedStatus == status ? CLColor.SwiftUI.primaryColor.opacity(0.1) : CLColor.SwiftUI.surface)
                            .cornerRadius(8)
                        }
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
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

// 이벤트 목록용 카드 컴포넌트
struct EventListCard: View {
    let event: Event
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 이미지 및 상태 배지
            ZStack(alignment: .topTrailing) {
                AsyncImage(url: URL(string: event.imageUrl)) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .fill(CLColor.SwiftUI.surface)
                            .aspectRatio(16/9, contentMode: .fill)
                            .frame(height: 180)
                            .cornerRadius(8)
                            .overlay {
                                ProgressView()
                            }
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 180)
                            .cornerRadius(8)
                            .clipped()
                    case .failure:
                        Rectangle()
                            .fill(CLColor.SwiftUI.surface)
                            .aspectRatio(16/9, contentMode: .fill)
                            .frame(height: 180)
                            .cornerRadius(8)
                            .overlay {
                                Image(systemName: "photo")
                                    .font(.largeTitle)
                                    .foregroundColor(CLColor.SwiftUI.textSecondary)
                            }
                    @unknown default:
                        Rectangle()
                            .fill(CLColor.SwiftUI.surface)
                            .aspectRatio(16/9, contentMode: .fill)
                            .frame(height: 180)
                            .cornerRadius(8)
                    }
                }
                
                // 상태 배지
                StatusBadge(status: event.status)
                    .padding([.top, .trailing], 12)
            }
            
            // 행사 정보
            VStack(alignment: .leading, spacing: 8) {
                Text(event.title)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(CLColor.SwiftUI.textPrimary)
                    .lineLimit(1)
                
                VStack(alignment: .leading, spacing: 6) {
                    // 날짜
                    HStack(spacing: 8) {
                        Image(systemName: "calendar")
                            .font(.system(size: 14))
                            .foregroundColor(CLColor.SwiftUI.textSecondary)
                        
                        Text(event.dateRange)
                            .font(.system(size: 15))
                            .foregroundColor(CLColor.SwiftUI.textSecondary)
                    }
                    
                    // 위치
                    HStack(spacing: 8) {
                        Image(systemName: "mappin.and.ellipse")
                            .font(.system(size: 14))
                            .foregroundColor(CLColor.SwiftUI.textSecondary)
                        
                        Text(event.address)
                            .font(.system(size: 15))
                            .foregroundColor(CLColor.SwiftUI.textSecondary)
                            .lineLimit(1)
                    }
                }
                
                // 간략한 설명
                Text(event.content)
                    .font(.system(size: 15))
                    .foregroundColor(CLColor.SwiftUI.textSecondary)
                    .lineLimit(2)
                    .padding(.top, 4)
                
                // 주최자 정보
                HStack {
                    if let manager = event.manager, let name = manager["name"] as? String {
                        Text("주최: \(name)")
                            .font(.system(size: 14))
                            .foregroundColor(CLColor.SwiftUI.textSecondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundColor(CLColor.SwiftUI.textSecondary)
                }
                .padding(.top, 8)
            }
            .padding(.horizontal, 4)
        }
        .padding(16)
        .background(CLColor.SwiftUI.backgroundBase)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

struct EventListView_Previews: PreviewProvider {
    static var previews: some View {
        EventListView()
    }
}
