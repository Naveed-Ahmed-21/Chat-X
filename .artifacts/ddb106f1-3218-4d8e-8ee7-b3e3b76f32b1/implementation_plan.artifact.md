# Fix Java/Gradle Incompatibility and Network Issues

The build is failing due to a mismatch between the Java version (25.0.2) and the Gradle version (8.14.5). Additionally, there are intermittent DNS resolution issues.

## Proposed Changes

### Environment Configuration

#### [MODIFY] Flutter JDK Configuration
I will configure Flutter to use the system's Java 21 (`/usr/lib/jvm/java-21-openjdk`) instead of the bundled Java 25. This will resolve the incompatibility with Gradle 8.14.5.

**Command:**
`flutter config --jdk-dir="/usr/lib/jvm/java-21-openjdk"`

### Network Resolution

#### [INFO] DNS Check
The "Temporary failure in name resolution" suggests the DNS server `172.26.202.37` provided by your connection was unreachable. If this persists, we can add a fallback DNS.

## Verification Plan

### Automated Tests
- Run `flutter doctor -v` to verify the new JDK path.
- Run `flutter run` to confirm the build completes and dependencies are downloaded.

### Manual Verification
- Observe the Gradle output to ensure the "incompatible with Gradle" error is gone.
