export interface Tide {
	time: string;
	type: "high" | "low";
	height: number;
}

export function nextHighTide(tides: Tide[], after: string): Tide {
	const next = tides.find(
		(t) => new Date(t.time) > new Date(after) && t.type === "high",
	);
	if (!next) throw new Error("no upcoming high tide in data");
	return next;
}
