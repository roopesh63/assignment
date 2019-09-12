import Foundation

let aSerial = DispatchQueue(label: "deadLock")

print(1)
aSerial.async {
    print(2)
    aSerial.sync {
        print(3)
    }
    print(4)
}
print(5)


