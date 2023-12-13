"use client"
import { Button, buttonVariants } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { cn } from "@/lib/utils";
import axios from "axios";
import { ImageIcon, Loader2, ScanSearch } from "lucide-react";
import Image from "next/image";
import Link from "next/link";
import React, { useState } from "react";

type Props = {};

const ImageClassificationPage = (props: Props) => {
  const [url, seturl] = useState("");
  const [label, setlabel] = useState("");
  const [loading, setLoading] = useState<boolean>(false);

  return (
    <main className="flex flex-col items-center justify-start p-24 gap-2">
      <form onSubmit={uploadFiles} className="flex gap-2 items-center">
        <ImageIcon />
        <Input name="files" type="file"></Input>
        <Button disabled={loading} type="submit">
          {loading ? (
            <Loader2 className="animate-spin" />
          ) : (
            <ScanSearch size={20} />
          )}
        </Button>
      </form>
      {url && (
        <>
          <Image
            src={url}
            width={400}
            height={400}
            alt={"uploaded image"}
          ></Image>
          <Link
            href={url}
            className={cn(
              buttonVariants({ variant: "ghost" }),
              "text-xs text-muted-foreground"
            )}
          ></Link>
        </>
      )}
      {label && <p className="font-bold text-l">Detected: {label}</p>}
    </main>
  );

  // handler functions
  async function uploadFiles(event: any) {
    event.preventDefault();
    const formData = new FormData(event.target);
    setLoading(true);
    const response = await axios.post("/api/detect-objects", formData);
    setLoading(false);
    // TODO: set state variables for url and label
    seturl(response.data.url);
    setlabel(response.data.label);
  }
};

export default ImageClassificationPage;
