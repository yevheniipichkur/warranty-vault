import ActivityKit
import SwiftUI
import WidgetKit

struct WarrantyVaultLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: WarrantyActivityAttributes.self) { context in
            LockScreenWarrantyActivityView(context: context)
                .activityBackgroundTint(Color(uiColor: .secondarySystemBackground))
                .activitySystemActionForegroundColor(.accentColor)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Label {
                        Text(context.state.itemName)
                            .font(.headline)
                            .lineLimit(1)
                    } icon: {
                        Image(systemName: "checkmark.shield.fill")
                    }
                }

                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(context.state.daysLeft)")
                            .font(.title3.weight(.bold))
                            .monospacedDigit()
                        Text("liveActivity.daysLeft")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }

                DynamicIslandExpandedRegion(.bottom) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("liveActivity.checkReceipt")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        ProgressView(value: progressValue(daysLeft: context.state.daysLeft))
                            .tint(.orange)
                    }
                }
            } compactLeading: {
                Image(systemName: "checkmark.shield.fill")
                    .foregroundStyle(.orange)
            } compactTrailing: {
                Text("\(context.state.daysLeft)d")
                    .font(.caption.weight(.semibold))
                    .monospacedDigit()
            } minimal: {
                Image(systemName: "shield.fill")
                    .foregroundStyle(.orange)
            }
        }
    }

    private func progressValue(daysLeft: Int) -> Double {
        let clamped = min(max(daysLeft, 0), 30)
        return Double(30 - clamped) / 30
    }
}

private struct LockScreenWarrantyActivityView: View {
    let context: ActivityViewContext<WarrantyActivityAttributes>

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "checkmark.shield.fill")
                .font(.title2.weight(.semibold))
                .foregroundStyle(.orange)
                .frame(width: 44, height: 44)
                .background(.orange.opacity(0.14), in: RoundedRectangle(cornerRadius: 14, style: .continuous))

            VStack(alignment: .leading, spacing: 5) {
                Text("liveActivity.status.expiringSoon")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.orange)
                Text(context.state.itemName)
                    .font(.headline)
                    .lineLimit(1)
                Text("liveActivity.checkReceipt")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Spacer(minLength: 8)

            VStack(alignment: .trailing, spacing: 3) {
                Text("\(context.state.daysLeft)")
                    .font(.title.weight(.bold))
                    .monospacedDigit()
                Text("liveActivity.daysLeft")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text(context.state.expirationDate, style: .date)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
    }
}
