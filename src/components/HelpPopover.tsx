import * as React from "react";
import { HelpCircle } from "lucide-react";
import { Popover, PopoverContent, PopoverTrigger } from "@/components/ui/popover";
import { Button } from "@/components/ui/button";
import { cn } from "@/lib/utils";
import { getHelp, type HelpEntry } from "@/lib/helpContent";

type Lang = "en" | "pt";

interface HelpPopoverProps {
  /** Route key into helpContent. If provided, content is loaded from the registry. */
  route?: string;
  /** Or pass an explicit entry. */
  entry?: HelpEntry;
  /** Visual size of the trigger icon. */
  size?: number;
  /** Extra className on the trigger button. */
  className?: string;
  /** Stop the click from bubbling to parent (e.g. NavLink). Defaults to true. */
  stopPropagation?: boolean;
}

/**
 * Hover-preview help popover that becomes "pinned" on click.
 * - Mouse enter on the icon: opens in preview mode.
 * - Mouse leave (preview mode only): closes.
 * - Click the icon OR click inside the preview: switches to pinned mode.
 * - Click "Done" (or Esc): closes a pinned popover.
 * - Click outside while pinned: stays open — only Done closes it.
 */
export function HelpPopover({
  route,
  entry: entryProp,
  size = 14,
  className,
  stopPropagation = true,
}: HelpPopoverProps) {
  const entry = entryProp ?? (route ? getHelp(route) : undefined);
  const [open, setOpen] = React.useState(false);
  const [pinned, setPinned] = React.useState(false);
  const [lang, setLang] = React.useState<Lang>("en");
  const closeTimer = React.useRef<number | null>(null);

  if (!entry) return null;

  const cancelClose = () => {
    if (closeTimer.current) {
      window.clearTimeout(closeTimer.current);
      closeTimer.current = null;
    }
  };

  const scheduleClose = () => {
    if (pinned) return;
    cancelClose();
    closeTimer.current = window.setTimeout(() => {
      setOpen(false);
    }, 120);
  };

  const handleEnter = () => {
    cancelClose();
    setOpen(true);
  };

  const handleLeave = () => {
    scheduleClose();
  };

  const handleTriggerClick = (e: React.MouseEvent) => {
    if (stopPropagation) {
      e.preventDefault();
      e.stopPropagation();
    }
    cancelClose();
    setOpen(true);
    setPinned(true);
  };

  const handleContentClick = (e: React.MouseEvent) => {
    e.stopPropagation();
    if (!pinned) setPinned(true);
  };

  const handleDone = (e: React.MouseEvent) => {
    e.stopPropagation();
    setPinned(false);
    setOpen(false);
  };

  return (
    <Popover
      open={open}
      onOpenChange={(o) => {
        // Only allow Radix to close the popover when not pinned.
        if (!o && pinned) return;
        if (!o) {
          setPinned(false);
          cancelClose();
        }
        setOpen(o);
      }}
    >
      <PopoverTrigger asChild>
        <button
          type="button"
          aria-label="Help"
          onMouseEnter={handleEnter}
          onMouseLeave={handleLeave}
          onClick={handleTriggerClick}
          className={cn(
            "inline-flex items-center justify-center rounded-full p-0.5 text-muted-foreground hover:text-foreground hover:bg-muted transition-colors",
            className,
          )}
        >
          <HelpCircle style={{ width: size, height: size }} />
        </button>
      </PopoverTrigger>
      <PopoverContent
        side="right"
        align="start"
        sideOffset={8}
        className="w-96 max-w-[90vw] text-sm"
        onMouseEnter={handleEnter}
        onMouseLeave={handleLeave}
        onClick={handleContentClick}
        // Block close-on-outside-click when pinned.
        onInteractOutside={(e) => {
          if (pinned) e.preventDefault();
        }}
        onEscapeKeyDown={() => {
          setPinned(false);
          setOpen(false);
        }}
      >
        <div className="flex items-start justify-between gap-2 mb-2">
          <h4 className="font-semibold text-foreground leading-tight">
            {entry.title[lang]}
          </h4>
          <div className="flex gap-1 shrink-0">
            <button
              type="button"
              onClick={(e) => { e.stopPropagation(); setLang("en"); }}
              className={cn(
                "px-1.5 py-0.5 text-xs rounded border",
                lang === "en"
                  ? "bg-primary text-primary-foreground border-primary"
                  : "border-border text-muted-foreground hover:text-foreground",
              )}
            >
              EN
            </button>
            <button
              type="button"
              onClick={(e) => { e.stopPropagation(); setLang("pt"); }}
              className={cn(
                "px-1.5 py-0.5 text-xs rounded border",
                lang === "pt"
                  ? "bg-primary text-primary-foreground border-primary"
                  : "border-border text-muted-foreground hover:text-foreground",
              )}
            >
              PT
            </button>
          </div>
        </div>

        <p className="text-muted-foreground mb-3">{entry.purpose[lang]}</p>

        {entry.howTo[lang].length > 0 && (
          <div className="mb-3">
            <p className="font-medium text-xs uppercase tracking-wide text-muted-foreground mb-1">
              {lang === "en" ? "How to use" : "Como usar"}
            </p>
            <ul className="list-disc pl-5 space-y-1 text-foreground">
              {entry.howTo[lang].map((step, i) => (
                <li key={i}>{step}</li>
              ))}
            </ul>
          </div>
        )}

        {entry.tips && entry.tips[lang].length > 0 && (
          <div className="mb-3">
            <p className="font-medium text-xs uppercase tracking-wide text-muted-foreground mb-1">
              {lang === "en" ? "Tips" : "Dicas"}
            </p>
            <ul className="list-disc pl-5 space-y-1 text-foreground">
              {entry.tips[lang].map((tip, i) => (
                <li key={i}>{tip}</li>
              ))}
            </ul>
          </div>
        )}

        <div className="flex justify-end pt-2 border-t border-border">
          {pinned ? (
            <Button size="sm" onClick={handleDone}>
              {lang === "en" ? "Done" : "Concluído"}
            </Button>
          ) : (
            <span className="text-xs text-muted-foreground italic">
              {lang === "en"
                ? "Click to keep open"
                : "Clique para manter aberto"}
            </span>
          )}
        </div>
      </PopoverContent>
    </Popover>
  );
}
