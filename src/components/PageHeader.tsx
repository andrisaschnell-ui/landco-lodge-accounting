import * as React from "react";
import { HelpPopover } from "@/components/HelpPopover";

interface PageHeaderProps {
  title: string;
  /** Route key into helpContent. Falls back to current pathname if not provided. */
  helpRoute?: string;
  description?: string;
  actions?: React.ReactNode;
  className?: string;
}

/**
 * Standard page header with an optional contextual help icon next to the title.
 * Pages can opt-in by replacing their existing <h1> with this component.
 */
export function PageHeader({
  title,
  helpRoute,
  description,
  actions,
  className,
}: PageHeaderProps) {
  const route =
    helpRoute ?? (typeof window !== "undefined" ? window.location.pathname : undefined);

  return (
    <div className={`flex items-start justify-between gap-4 mb-4 ${className ?? ""}`}>
      <div className="min-w-0">
        <div className="flex items-center gap-2">
          <h1 className="text-2xl font-bold text-foreground truncate">{title}</h1>
          {route && <HelpPopover route={route} size={18} />}
        </div>
        {description && (
          <p className="text-sm text-muted-foreground mt-1">{description}</p>
        )}
      </div>
      {actions && <div className="shrink-0 flex items-center gap-2">{actions}</div>}
    </div>
  );
}
