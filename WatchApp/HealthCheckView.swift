import SwiftUI

/// Phase 0 spike: can this build (signed with a free Personal Team) use HealthKit?
struct HealthCheckView: View {
#if NO_HEALTHKIT
    var body: some View {
        VStack(spacing: 6) {
            Text("Health check")
                .font(.headline)
            Text("This build was made with NO_HEALTHKIT, so HealthKit is compiled out.")
                .font(.footnote)
                .multilineTextAlignment(.center)
        }
    }
#else
    @State private var model = HealthCheckModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 6) {
                ForEach(model.steps) { step in
                    StepRow(step: step)
                }
                Button(model.isRunning ? "Running..." : "Run check") {
                    model.run()
                }
                .disabled(model.isRunning)
                if let verdict = model.verdict {
                    Text(verdict)
                        .font(.footnote.bold())
                        .foregroundStyle(model.allPassed ? .green : .red)
                }
            }
        }
        .navigationTitle("Health")
    }
#endif
}

#if !NO_HEALTHKIT
private struct StepRow: View {
    let step: HealthCheckModel.Step

    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            Text("\(step.status.symbol) \(step.title)")
                .font(.footnote.bold())
            if let detail = step.status.detail {
                Text(detail)
                    .font(.caption2)
                    .foregroundStyle(step.status.isFailure ? .red : .secondary)
            }
        }
    }
}
#endif
