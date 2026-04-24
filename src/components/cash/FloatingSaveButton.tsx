import { Button } from "@/components/ui/button";
import { Save } from "lucide-react";

interface Props {
  dirtyCount: number;
  onSave: () => void;
}

/**
 * Floating Save pill, bottom-right, sits above the ZoomControl.
 * Only visible when there are unsaved changes.
 */
export function FloatingSaveButton({ dirtyCount, onSave }: Props) {
  if (dirtyCount === 0) return null;
  return (
    <div className="fixed bottom-20 right-4 z-50">
      <Button
        onClick={onSave}
        size="lg"
        className="rounded-full shadow-lg gap-2"
        aria-label={`Save ${dirtyCount} unsaved change${dirtyCount === 1 ? "" : "s"}`}
      >
        <Save className="h-4 w-4" />
        Save ({dirtyCount})
      </Button>
    </div>
  );
}
