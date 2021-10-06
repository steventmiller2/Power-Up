//
//  HealthKitMetrics.swift
//  Power-Up WatchKit Extension
//
//  Created by Steven Miller on 9/26/21.
//

import Foundation
import HealthKit
import Combine

/**
 HealthKitMetrics manages the workout and the workout metrics
 */
class HealthKitMetrics: NSObject, ObservableObject {

    /**
     These attributes are necessary for building the workout. They will define the type of workout
     */
    let configuration = HKWorkoutConfiguration()
    var workoutSession: HKWorkoutSession!
    var workoutBuilder: HKLiveWorkoutBuilder!
    let healthStore = HKHealthStore()

    /**
     Empty Constructor
     */
    override init() {
        super.init()
    }

    // MARK: - Authorize HK
    /**
     Access to Healthkit metrics requires asking permission from the user.
     Particularly, this method asks for read and share access on specific health metrics.
     */
    func authorizeHealthKit() {
        if HKHealthStore.isHealthDataAvailable() {
            let infoToRead = Set([
                HKSampleType.quantityType(forIdentifier: .stepCount)!,
                HKSampleType.quantityType(forIdentifier: .heartRate)!,
                HKSampleType.quantityType(forIdentifier: .activeEnergyBurned)!,
                HKSampleType.quantityType(forIdentifier: .distanceWalkingRunning)!,
                HKSampleType.quantityType(forIdentifier: .walkingSpeed)!,
                HKSampleType.workoutType()
                ])

            let infoToShare = Set([
                HKSampleType.quantityType(forIdentifier: .stepCount)!,
                HKSampleType.quantityType(forIdentifier: .heartRate)!,
                HKSampleType.quantityType(forIdentifier: .activeEnergyBurned)!,
                HKSampleType.quantityType(forIdentifier: .distanceWalkingRunning)!,
                HKSampleType.quantityType(forIdentifier: .walkingSpeed)!,
                HKSampleType.workoutType()
                ])

            healthStore.requestAuthorization(toShare: infoToShare, read: infoToRead) { (success, error) in
                if success {
                    print("Authorization healthkit success")
                    self.startWorkout()
                } else if let error = error {
                    print(error)
                }
            }
        } else {
            print("HealthKit not avaiable")
        }
    }

    // MARK: - Configure
    /**
     This is where the workout is configured as a running workout. Additionally, workoutSession and workoutBuilder are configured.
     */
    private func configWorkout() {
        configuration.activityType = .running

        do {
            workoutSession = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
            workoutBuilder = workoutSession.associatedWorkoutBuilder()
        } catch {
            return
        }

        workoutSession.delegate = self
        workoutBuilder.delegate = self

        workoutBuilder.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: configuration)
    }
    
    /**
     These are the attributes for the workout metrics that will be tracked
     */
    @Published var heartrate: Double = 0
    @Published var activeCalories: Double = 0
    @Published var distance: Double = 0
    @Published var elapsedSeconds: Int = 0
    @Published var pace: Double = 0

    // MARK: - Start Workout
    func startWorkout() {
        setUpTimer()
        configWorkout()
        workoutSession.startActivity(with: Date())
        workoutBuilder.beginCollection(withStart: Date()) { (success, error) in
            print("Start workout: \(success)")
            if let error = error {
                print(error)
            }
        }
    }
    
    // MARK: - End Workout
    /**
     Currently not being used
     */
    func endWorkout() {
        // End the workout session.
        workoutSession.end()
        cancellable?.cancel()
    }

    // MARK: - Timer Setup
    // The cancellable holds the timer publisher.
    var start: Date = Date()
    var cancellable: Cancellable?
    var accumulatedTime: Int = 0

    // Set up and start the timer.
    private func setUpTimer() {
        start = Date()
        cancellable = Timer.publish(every: 0.1, on: .main, in: .default)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.elapsedSeconds = self.incrementElapsedTime()
            }
    }

    // Calculate the elapsed time.
    private func incrementElapsedTime() -> Int {
        let runningTime: Int = Int(-1 * (self.start.timeIntervalSinceNow))
        return self.accumulatedTime + runningTime
    }

    // MARK: - Metrics
    func updateForStatistics(_ statistics: HKStatistics?) {
        guard let statistics = statistics else { return }

        DispatchQueue.main.async {
            switch statistics.quantityType {
            case HKQuantityType.quantityType(forIdentifier: .heartRate):
                /// - Tag: SetLabel
                let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
                let value = statistics.mostRecentQuantity()?.doubleValue(for: heartRateUnit)
                let roundedValue = Double( round( 1 * value! ) / 1 )
                self.heartrate = roundedValue
            case HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned):
                let energyUnit = HKUnit.kilocalorie()
                let value = statistics.sumQuantity()?.doubleValue(for: energyUnit)
                self.activeCalories = Double( round( 1 * value! ) / 1 )
                return
            case HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning):
                let distanceUnit = HKUnit.mile()
                let value = statistics.sumQuantity()?.doubleValue(for: distanceUnit)
                let roundedValue = Double( round( 100 * value! ) / 100 )
                self.distance = roundedValue
                return
            default:
                return
            }
            self.getPace()
        }
    }

    /**
     This function calculates the runners pace based on distance and time
     */
    func getPace() {
        let elapsedSecondsDouble = Double(elapsedSeconds)
        let elapsedHours = Double(elapsedSecondsDouble/3600)
        let value = Double(distance/elapsedHours)
        let roundedValue = Double( round( 10 * value ) / 10 )
        self.pace = roundedValue
        return
    }
}

// MARK: - SessionDelegate
/**
 A session delegate is required for running a workout session. The 'workoutSession' functions within it are required per the HKWorkoutSessionDelegate protocol.
 */
extension HealthKitMetrics: HKWorkoutSessionDelegate {
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState,
                        from fromState: HKWorkoutSessionState, date: Date) {
    }
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {

    }
}

// MARK: - BuilderDelegate
extension HealthKitMetrics: HKLiveWorkoutBuilderDelegate {
    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
    }

    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        for type in collectedTypes {
            guard let quantityType = type as? HKQuantityType else {
                return // Nothing to do.
            }

            //Get Metrics
            let healthMetrics = workoutBuilder.statistics(for: quantityType)

            // Update the published values.
            updateForStatistics(healthMetrics)
            print("HeartRate: \(heartrate)")
            print("Pace: \(pace)")
        }
    }
}
