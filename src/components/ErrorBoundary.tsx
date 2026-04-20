import { Component, ReactNode } from "react";

interface Props {
  children?: ReactNode;
}

interface State {
  hasError: boolean;
  errorStr: string;
}

export class ErrorBoundary extends Component<Props, State> {
  public state: State = {
    hasError: false,
    errorStr: ""
  };

  public static getDerivedStateFromError(error: Error): State {
    return { hasError: true, errorStr: error.toString() + "\n" + error.stack };
  }

  public render() {
    if (this.state.hasError) {
      return (
        <div className="p-8 text-red-500 font-mono text-sm whitespace-pre-wrap">
          <h1>React Crash Detected:</h1>
          {this.state.errorStr}
        </div>
      );
    }

    return this.props.children;
  }
}
