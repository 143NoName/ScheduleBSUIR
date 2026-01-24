//
//  PersonalAccount.swift
//  ScheduleBSUIR
//
//  Created by user on 5.11.25.
//

import SwiftUI
import PhotosUI

struct PersonalAccount: View {
    
    @Environment(NetworkViewModelForListGroups.self) var groupListViewModel
    @Environment(NetworkViewModelForListEmployees.self) var employeeListViewModel
    @Environment(NetworkViewModelForScheduleEmployees.self) var employeeScheduleViewModel
//    @Environment(\.appStorageSaveService) var appStorageSaveKey // ключи AppStorage
    
    @Environment(\.colorScheme) var colorScheme
    
    var appStorage = SaveForWidgetService()
        
    @State private var isShowPhotosPicker: Bool = false
    @State private var selectedItem: PhotosPickerItem?       // для photosPicker
    #warning("Надо бы сохранять изображение в приложении")
    @State private var userPhoto: UIImage? = nil             // само изображение
    
//    @State private var isShowSettings: Bool = false

    @State private var studentName: String = ""
    @State private var studentSurname: String = ""
    @State private var studentPatronymic: String = ""
        
    @AppStorage("whoUser", store: UserDefaults(suiteName: "group.foAppAndWidget.ScheduleBSUIR")) var whoUser: WhoUser = .none
    @AppStorage("employeeName", store: UserDefaults(suiteName: "group.foAppAndWidget.ScheduleBSUIR")) var employeeName: String = "Не выбрано"
    @AppStorage("favoriteGroup", store: UserDefaults(suiteName: "group.foAppAndWidget.ScheduleBSUIR")) var favoriteGroup: String = "Не выбрано"
    @AppStorage("subGroup", store: UserDefaults(suiteName: "group.foAppAndWidget.ScheduleBSUIR")) var subGroup: Int = 0
    
    func getListStudentOrEmployees() {
        Task {
            if whoUser == .student {
                await groupListViewModel.getArrayOfGroupNum()
            } else if whoUser == .employee {
                await employeeListViewModel.getArrayOfEmployees()
                if employeeName != "Не выбрано" {
                    await employeeScheduleViewModel.getEachEmployeeSchedule(employeeName)
                }
            }
        }
    }
    
    func loadPhotoFromPhotoPicker(from image: PhotosPickerItem?) {
        guard let image else { return }
        
        Task {
            do {
                if let data = try await image.loadTransferable(type: Data.self) {
                    // Создаем UIImage из данных
                    if let uiImage = UIImage(data: data) {
                        await MainActor.run {
                            withAnimation {
                                self.userPhoto = uiImage
                            }
                        }
                    }
                }
            } catch {
                print("Ошибка загрузки: \(error)")
            }
        }
    }
    
    func clearPhoto() {
        withAnimation {
            userPhoto = nil
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                if colorScheme == .light {
                    Color.gray
                        .opacity(0.15)
                        .ignoresSafeArea(edges: .all)
                }
                VStack {
                    List {
                        Section {
                            ZStack(alignment: .bottomTrailing) {
                                Image(uiImage: userPhoto ?? UIImage(named: "PlainPhoto")!)
                                    .resizable()
                                    .frame(width: 150, height: 150)
                                    .clipShape(Circle())
                                    .padding(.horizontal, 10)
                                
                                Menu {
                                    Button {
                                        clearPhoto()
                                    } label: {
                                        HStack {
                                            Image(systemName: "trash")
                                            Text("Вернуть исходное фото")
                                        }
                                    }
                                    Button {
                                        isShowPhotosPicker.toggle()
                                    } label: {
                                        HStack {
                                            Image(systemName: "photo.badge.plus")
                                            Text("Добавить фото")
                                        }
                                    }
                                } label: {
                                    Image(systemName: "photo")
                                        .tint(Color.primary.opacity(0.8))
                                }
                            }
                            if whoUser == .employee {
                                Section {
                                    if employeeListViewModel.isLoadingScheduleForEmployees {
                                        ProgressView()
                                    } else {
                                        VStack {
                                            Text("\(employeeScheduleViewModel.scheduleForEachEmployee.employeeDto.fullName)")
                                            Text("\(employeeScheduleViewModel.scheduleForEachEmployee.employeeDto.email ?? "")")
                                            Text("\(employeeScheduleViewModel.scheduleForEachEmployee.employeeDto.fullName)")
                                        }
                                    }
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        
                        
                        if whoUser == .student {
                            Section(header: Text("ФИО")) {
                                TextField("Твое имя", text: $studentName)
                                TextField("Твоя фамилия", text: $studentSurname)
                                TextField("Твое отчество", text: $studentPatronymic)
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .photosPicker(isPresented: $isShowPhotosPicker, selection: $selectedItem, matching: .images)
                    .onChange(of: selectedItem) { _, newValue in
                        loadPhotoFromPhotoPicker(from: newValue) // изменение фото
                    }
                    #warning("Пикер работает, но загружается одно фото на все приложение")
                }
                
                SelectorViewForPersonalAccount()
                
                .navigationBarTitle("Личный кабинет")
                
                
                
//                .onChange(of: whoUser) {
//                    getListStudentOrEmployees() // получение списка преподавателей или учеников
//                }
            }
            
//            .onChange(of: appStorageSaveKey.whoUser) {
//                getListStudentOrEmployees()
//            }
            
            .refreshable {
                getListStudentOrEmployees()
            }
//            .navigationDestination(for: InEditProfile.self) { parametr in
//                EditProfile(parametr: parametr)
//            }
        }
    }
}

#Preview() {
    @Previewable @State var whoUser: WhoUser = .employee
    #warning("Не видит из за виджета (таргета)")
    
    NavigationView {
        PersonalAccount()
            .environment(NetworkViewModelForListGroups())
            .environment(NetworkViewModelForListEmployees())
            .environment(NetworkViewModelForScheduleEmployees())
//            .environment(\.appStorageSaveService, appStorageAppStorageSave)
    }
}
