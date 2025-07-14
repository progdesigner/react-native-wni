# react-native-wni

React Native WebView에서 네이티브 디바이스/앱/OS 정보 및 명령 브릿지를 제공합니다.

## 설치

```sh
npm install react-native-wni
```

## 빌드 (패키지 개발자용)

```sh
npm run build
```

## 사용법

```ts
import WNInterface from 'react-native-wni';
// WNInterface 사용 예시
```

## 실제 사용 예시 (함수형 컴포넌트)

```tsx
import React, { useRef, useEffect } from 'react';
import { WebView } from 'react-native-webview';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { WNInterface } from 'react-native-wni';

export default function MyWebViewScreen() {
  const webViewRef = useRef<WebView>(null);
  const insets = useSafeAreaInsets();
  const wni = new WNInterface({ controller: webViewRef });

  useEffect(() => {
    wni.setupAndroidSafeArea(insets);
  }, [insets]);

  return (
    <WebView
      ref={webViewRef}
      source={{ uri: 'https://your-web-url.com' }}
      onMessage={wni.handleMessage}
    />
  );
}
```

## 패키지 정보
- main: dist/index.js
- types: dist/index.d.ts 