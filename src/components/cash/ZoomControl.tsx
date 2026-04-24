import { useEffect, useState } from "react";
import { Button } from "@/components/ui/button";
import { Minus, Plus, RotateCcw } from "lucide-react";

interface ZoomControlProps {
  /** Storage key, e.g. `cash-zoom:petty_cash` */
  storageKey: string;
  /** Called whenever the zoom value changes (in %). Parent applies it to its content. */
  onChange: (zoomPercent: number) => void;
  min?: number;
  max?: number;
  step?: number;
}

/**
 * Floating zoom pill (bottom-right). Persists per-page in localStorage.
 * Range 50%–200% in 10% steps by default.
 */
export function ZoomControl({
  storageKey,
  onChange,
  min = 50,
  max = 200,
  step = 10,
}: ZoomControlProps) {
  const [zoom, setZoom] = useState<number>(() => {
    if (typeof window === "undefined") return 100;
    const raw = window.localStorage.getItem(storageKey);
    const n = raw ? Number(raw) : 100;
    return Number.isFinite(n) ? Math.min(max, Math.max(min, n)) : 100;
  });

  useEffect(() => {
    onChange(zoom);
    try {
      window.localStorage.setItem(storageKey, String(zoom));
    } catch {
      /* ignore quota errors */
    }
  }, [zoom, storageKey, onChange]);

  const dec = () => setZoom((z) => Math.max(min, z - step));
  const inc = () => setZoom((z) => Math.min(max, z + step));
  const reset = () => setZoom(100);

  return (
    <div
      className="fixed bottom-4 right-4 z-50 flex items-center gap-1 rounded-full border bg-background/95 px-2 py-1 shadow-lg backdrop-blur"
      role="group"
      aria-label="Zoom controls"
    >
      <Button
        variant="ghost"
        size="icon"
        className="h-8 w-8 rounded-full"
        onClick={dec}
        disabled={zoom <= min}
        aria-label="Zoom out"
      >
        <Minus className="h-4 w-4" />
      </Button>
      <button
        type="button"
        onClick={reset}
        className="min-w-[3.5rem] rounded-full px-2 py-1 text-xs font-mono font-semibold tabular-nums hover:bg-muted"
        title="Reset to 100%"
        aria-label={`Current zoom ${zoom} percent. Click to reset.`}
      >
        {zoom}%
      </button>
      <Button
        variant="ghost"
        size="icon"
        className="h-8 w-8 rounded-full"
        onClick={inc}
        disabled={zoom >= max}
        aria-label="Zoom in"
      >
        <Plus className="h-4 w-4" />
      </Button>
      <Button
        variant="ghost"
        size="icon"
        className="h-8 w-8 rounded-full"
        onClick={reset}
        aria-label="Reset zoom"
        title="Reset to 100%"
      >
        <RotateCcw className="h-3.5 w-3.5" />
      </Button>
    </div>
  );
}
