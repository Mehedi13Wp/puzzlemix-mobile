# Pigeon JNI calls Kotlin suspend functions by their original JVM descriptors.
# https://github.com/flutter/packages/blob/main/packages/pigeon/native_interop_guide.md
# Keep these Kotlin runtime types so R8 cannot rewrite those descriptors.
-keep class kotlin.Unit { *; }
-keep class kotlin.Result { *; }
-keep class kotlin.Result$Failure { *; }
-keep class kotlin.coroutines.Continuation { *; }
-keep class kotlin.coroutines.intrinsics.CoroutineSingletons { *; }
-keep class kotlin.coroutines.intrinsics.IntrinsicsKt { *; }
