//
//  ReactionBarView.swift
//  PetApp
//
//  Created by Alumno on 18/04/26.
//

import SwiftUI

struct ReactionBarView: View {
    let idPublicacion: UUID
    @StateObject private var vm: ReactionViewModel

    init(idPublicacion: UUID) {
        self.idPublicacion = idPublicacion
        _vm = StateObject(wrappedValue: ReactionViewModel(idPublicacion: idPublicacion))
    }

    var body: some View {
        HStack(spacing: 8) {
            // Botón principal
            Button {
                if let id = vm.miReaccion,
                   let tipo = vm.tipos.first(where: { $0.id == id }) {
                    Task { await vm.reaccionar(tipo: tipo) }
                } else {
                    vm.showPicker.toggle()
                }
            } label: {
                HStack(spacing: 5) {
                    Text(vm.tipos.first(where: { $0.id == vm.miReaccion })?.icono ?? "🤍")
                        .font(.system(size: 18))

                    if vm.totalReacciones > 0 {
                        Text("\(vm.totalReacciones)")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(vm.miReaccion != nil ? AppColors.primary : AppColors.textSecondary)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(vm.miReaccion != nil ? AppColors.primary.opacity(0.12) : AppColors.card)
                .clipShape(Capsule())
                .overlay(
                    Capsule().stroke(
                        vm.miReaccion != nil ? AppColors.primary.opacity(0.3) : Color.clear,
                        lineWidth: 1
                    )
                )
            }
            .onLongPressGesture { vm.showPicker = true }

            // Top 3
            ForEach(vm.top3, id: \.idTipo) { r in
                Button {
                    if let tipo = vm.tipos.first(where: { $0.id == r.idTipo }) {
                        Task { await vm.reaccionar(tipo: tipo) }
                    }
                } label: {
                    HStack(spacing: 3) {
                        Text(r.icono).font(.system(size: 15))
                        Text("\(r.total)")
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(AppColors.textSecondary)
                    }
                    .padding(.horizontal, 9)
                    .padding(.vertical, 6)
                    .background(
                        vm.miReaccion == r.idTipo
                        ? AppColors.primary.opacity(0.12)
                        : AppColors.softBeige.opacity(0.6)
                    )
                    .clipShape(Capsule())
                }
            }
        }
        .task { await vm.cargar() }
        .popover(isPresented: $vm.showPicker) {
            EmojiPickerView(tipos: vm.tipos, miReaccion: vm.miReaccion) { tipo in
                Task { await vm.reaccionar(tipo: tipo) }
            }
            .presentationCompactAdaptation(.popover)
        }
    }
}

// MARK: - Picker
struct EmojiPickerView: View {
    let tipos: [TipoReaccion]
    let miReaccion: UUID?
    let onSelect: (TipoReaccion) -> Void

    var body: some View {
        HStack(spacing: 4) {
            ForEach(tipos) { tipo in
                Button {
                    onSelect(tipo)
                } label: {
                    Text(tipo.icono)
                        .font(.system(size: 28))
                        .padding(8)
                        .background(
                            miReaccion == tipo.id
                            ? AppColors.primary.opacity(0.15)
                            : Color.clear
                        )
                        .clipShape(Circle())
                        .scaleEffect(miReaccion == tipo.id ? 1.2 : 1.0)
                        .animation(.spring(response: 0.3), value: miReaccion)
                }
                .accessibilityLabel(tipo.nombre)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(AppColors.card)
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}
