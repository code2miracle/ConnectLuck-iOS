//
//  EventDetailView.swift
//  ConnectLuck
//
//  Created by 이종민 on 3/14/25.
//

import SwiftUI

    struct EventDetailView: View {
    let eventId: Int
    @State private var detailViewModel = EventDetailViewModel()
    @State private var showApplicationForm = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // 이미지 및 상태 배지
                headerImage
                
                // 이벤트 정보
                VStack(alignment: .leading, spacing: 16) {
                    // 제목 및 상태
                    titleSection
                    
                    Divider()
                        .background(CLColor.SwiftUI.divider)
                    
                    // 주요 정보
                    infoSection
                    
                    // 설명
                    descriptionSection
                    
                    Divider()
                        .background(CLColor.SwiftUI.divider)
                    
                    // 주최자 정보
                    organizerSection
                    
                    // 신청 버튼
                    applicationButton
                }
                .padding(16)
            }
        }
        .background(CLColor.SwiftUI.backgroundBase)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
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
            await detailViewModel.fetchEventDetail(id: eventId)
        }
        .alert(isPresented: $detailViewModel.showError) {
            Alert(
                title: Text("데이터 로드 실패"),
                message: Text(detailViewModel.errorMessage ?? "오류가 발생했습니다."),
                dismissButton: .default(Text("확인"))
            )
        }
    }
    
    // 헤더 이미지
    private var headerImage: some View {
        ZStack(alignment: .topTrailing) {
            if let event = detailViewModel.eventDetail {
                AsyncImage(url: URL(string: event.imageUrl)) { phase in
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
                
                // 상태 배지
                StatusBadge(status: event.status)
                    .padding([.top, .trailing], 16)
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
    
    // 제목 섹션
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let event = detailViewModel.eventDetail {
                Text(event.title)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(CLColor.SwiftUI.textPrimary)
            } else {
                Rectangle()
                    .fill(CLColor.SwiftUI.surface)
                    .frame(height: 28)
                    .cornerRadius(4)
            }
        }
    }
    
    // 정보 섹션
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let event = detailViewModel.eventDetail {
                // 날짜
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "calendar")
                        .font(.system(size: 16))
                        .foregroundColor(CLColor.SwiftUI.primaryColor)
                        .frame(width: 24)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("행사 일정")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(CLColor.SwiftUI.textPrimary)
                        
                        Text(event.dateRange)
                            .font(.system(size: 15))
                            .foregroundColor(CLColor.SwiftUI.textSecondary)
                    }
                }
                
                // 위치
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 16))
                        .foregroundColor(CLColor.SwiftUI.primaryColor)
                        .frame(width: 24)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("행사 장소")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(CLColor.SwiftUI.textPrimary)
                        
                        Text(event.address)
                            .font(.system(size: 15))
                            .foregroundColor(CLColor.SwiftUI.textSecondary)
                    }
                }
            } else {
                // 로딩 중인 경우의 스켈레톤 UI
                ForEach(0..<2, id: \.self) { _ in
                    HStack(spacing: 12) {
                        Rectangle()
                            .fill(CLColor.SwiftUI.surface)
                            .frame(width: 24, height: 24)
                            .cornerRadius(4)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Rectangle()
                                .fill(CLColor.SwiftUI.surface)
                                .frame(height: 18)
                                .frame(width: 80)
                                .cornerRadius(4)
                            
                            Rectangle()
                                .fill(CLColor.SwiftUI.surface)
                                .frame(height: 16)
                                .cornerRadius(4)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }
    
    // 설명 섹션
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("행사 소개")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(CLColor.SwiftUI.textPrimary)
            
            if let event = detailViewModel.eventDetail {
                Text(event.content)
                    .font(.system(size: 16))
                    .foregroundColor(CLColor.SwiftUI.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                // 로딩 중인 경우의 스켈레톤 UI
                Rectangle()
                    .fill(CLColor.SwiftUI.surface)
                    .frame(height: 100)
                    .cornerRadius(4)
            }
        }
        .padding(.vertical, 8)
    }
    
    // 주최자 정보 섹션
    private var organizerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("주최자 정보")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(CLColor.SwiftUI.textPrimary)
            
//            if let event = detailViewModel.eventDetail, let manager = event.managerName {
//                VStack(alignment: .leading, spacing: 12) {
//                    // 주최자 이름
//                    if let name = manager["name"] as? String {
//                        HStack(spacing: 12) {
//                            Image(systemName: "person.fill")
//                                .font(.system(size: 16))
//                                .foregroundColor(CLColor.SwiftUI.primaryColor)
//                                .frame(width: 24)
//                            
//                            Text(name)
//                                .font(.system(size: 16))
//                                .foregroundColor(CLColor.SwiftUI.textPrimary)
//                        }
//                    }
//                    
//                    // 주최자 연락처
//                    if let phone = manager["phone"] as? String {
//                        HStack(spacing: 12) {
//                            Image(systemName: "phone.fill")
//                                .font(.system(size: 16))
//                                .foregroundColor(CLColor.SwiftUI.primaryColor)
//                                .frame(width: 24)
//                            
//                            Text(phone)
//                                .font(.system(size: 16))
//                                .foregroundColor(CLColor.SwiftUI.textPrimary)
//                        }
//                    }
//                }
//            } else {
//                // 로딩 중인 경우의 스켈레톤 UI
//                ForEach(0..<2, id: \.self) { _ in
//                    HStack(spacing: 12) {
//                        Rectangle()
//                            .fill(CLColor.SwiftUI.surface)
//                            .frame(width: 24, height: 24)
//                            .cornerRadius(4)
//                        
//                        Rectangle()
//                            .fill(CLColor.SwiftUI.surface)
//                            .frame(height: 16)
//                            .cornerRadius(4)
//                    }
//                    .padding(.vertical, 4)
//                }
//            }
        }
        .padding(.vertical, 8)
    }
    
    // 신청 버튼
    private var applicationButton: some View {
        VStack {
            if let event = detailViewModel.eventDetail {
                if event.status == .applicationFinished || event.status == .beforeApplication {
                    PrimaryButton(text: "푸드트럭 참가 신청하기") {
                        showApplicationForm = true
                    }
                    .padding(.top, 16)
                } else {
                    Text("현재 신청이 불가능한 상태입니다")
                        .font(.system(size: 16))
                        .foregroundColor(CLColor.SwiftUI.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 16)
                }
            } else {
                Rectangle()
                    .fill(CLColor.SwiftUI.surface)
                    .frame(height: 50)
                    .cornerRadius(8)
                    .padding(.top, 16)
            }
        }
    }
}

class EventDetailViewModel: ObservableObject {
    @Published var eventDetail: Event?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false
    
    func fetchEventDetail(id: Int) async {
        isLoading = true
        errorMessage = nil
        showError = false
        
        do {
            let detail = try await EventService.shared.fetchEventDetail(id: id)
            
            DispatchQueue.main.async {
                self.eventDetail = detail
                self.isLoading = false
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "상세 정보를 불러오는데 실패했습니다: \(error.localizedDescription)"
                self.showError = true
                self.isLoading = false
            }
            
            print("상세 정보 로드 오류: \(error.localizedDescription)")
        }
    }
}

struct EventDetailView_Previews: PreviewProvider {
    static var previews: some View {
        EventDetailView(eventId: 1)
    }
}
